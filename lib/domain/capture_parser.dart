import 'dart:math';

import 'package:meta/meta.dart';

import '../l10n/capture_words.dart';
import 'enums.dart';
import 'item.dart';
import 'local_date.dart';

/// The things smart capture can read out of a line (FR-01a). Each one shows
/// as a chip before saving; tapping a chip puts its words back in the title.
enum CapturePart { when, time, deadline, list, mustDo, waiting, effort, repeat }

/// A repeat read from a capture: "every Monday", "monthly on the 1st".
@immutable
class CaptureRepeat {
  const CaptureRepeat({
    required this.freq,
    this.interval = 1,
    this.weekdays = const {},
    this.monthDay,
  });

  final RepeatFrequency freq;
  final int interval;
  final Set<int> weekdays;
  final int? monthDay;

  @override
  bool operator ==(Object other) =>
      other is CaptureRepeat &&
      other.freq == freq &&
      other.interval == interval &&
      other.weekdays.length == weekdays.length &&
      other.weekdays.containsAll(weekdays) &&
      other.monthDay == monthDay;

  @override
  int get hashCode =>
      Object.hash(freq, interval, Object.hashAllUnordered(weekdays), monthDay);

  @override
  String toString() => 'CaptureRepeat($freq/$interval $weekdays $monthDay)';
}

/// What [parseCapture] found in one line of text.
@immutable
class ParsedCapture {
  const ParsedCapture({
    required this.title,
    required this.original,
    this.date,
    this.time,
    this.horizon,
    this.deadline,
    this.listId,
    this.mustDo = false,
    this.waitingOn,
    this.effort,
    this.repeat,
  });

  /// The text with everything understood taken out.
  final String title;

  /// Exactly what was typed.
  final String original;
  final LocalDate? date;

  /// Minutes from midnight; set only with [date].
  final int? time;

  /// Today or This week, when no date was given.
  final WhenHorizon? horizon;
  final LocalDate? deadline;
  final String? listId;
  final bool mustDo;
  final String? waitingOn;
  final int? effort;
  final CaptureRepeat? repeat;

  /// Which kinds of thing were found.
  Set<CapturePart> get parts => {
    if (date != null || horizon != null) CapturePart.when,
    if (time != null) CapturePart.time,
    if (deadline != null) CapturePart.deadline,
    if (listId != null) CapturePart.list,
    if (mustDo) CapturePart.mustDo,
    if (waitingOn != null) CapturePart.waiting,
    if (effort != null) CapturePart.effort,
    if (repeat != null) CapturePart.repeat,
  };

  bool get isPlain => parts.isEmpty;

  /// Whether this capture says when to do it (so it can skip the Inbox).
  bool get hasPlan =>
      date != null || horizon != null || repeat != null || mustDo;

  @override
  String toString() =>
      'ParsedCapture("$title", date: $date, time: $time, horizon: $horizon, '
      'deadline: $deadline, list: $listId, mustDo: $mustDo, '
      'waiting: $waitingOn, effort: $effort, repeat: $repeat)';
}

/// Rounds [minutes] up to the nearest of [Item.effortSteps].
int snapEffort(int minutes) => Item.effortSteps.firstWhere(
  (step) => minutes <= step,
  orElse: () => Item.effortSteps.last,
);

/// Reads dates, times, repeats, lists and flags out of [text] (FR-01a):
/// "pay rent fri 9am #home !" is *Pay rent* on Friday at 09:00, filed under
/// Home, as a must-do.
///
/// Rule-based and offline: nothing leaves the phone. [lists] maps list names
/// to ids, for `#list`. [ignore] leaves those parts in the title, which is
/// how a chip is taken back. [dayFirst] reads `3/4` as the 3rd of April.
ParsedCapture parseCapture(
  String text, {
  required LocalDate today,
  int nowMinutes = 0,
  int weekStart = DateTime.monday,
  bool dayFirst = true,
  Map<String, String> lists = const {},
  Set<CapturePart> ignore = const {},
}) {
  final parser = _Parser(
    text,
    today: today,
    nowMinutes: nowMinutes,
    weekStart: weekStart,
    dayFirst: dayFirst,
    lists: lists,
    ignore: ignore,
  );
  return parser.run();
}

/// Start and end of a word, in any script: no letter, digit or combining
/// mark (Devanagari vowel signs) just outside it.
const _b = r"(?<![\p{L}\p{N}\p{M}])";
const _e = r"(?![\p{L}\p{N}\p{M}'’]|\.[\p{L}\p{N}])";

String _alt(Iterable<String> words) {
  final sorted = words.toSet().toList()
    ..sort((a, b) => b.length.compareTo(a.length));
  return sorted.map((w) => RegExp.escape(w).replaceAll(' ', r'\s+')).join('|');
}

RegExp _re(String pattern) =>
    RegExp(pattern, caseSensitive: false, unicode: true);

final _weekdayByWord = {
  for (final MapEntry(key: day, value: words) in weekdayWords.entries)
    for (final word in words) word: day,
};
final _monthByWord = {
  for (final MapEntry(key: month, value: words) in monthWords.entries)
    for (final word in words) word: month,
};
final _weekdayAlt = _alt(_weekdayByWord.keys);
final _monthAlt = _alt(_monthByWord.keys);
final _numberAlt = r'\d+|' + _alt(numberWords.keys);
const _ordinal = r'(?:st|nd|rd|th)?';

int? _number(String word) =>
    int.tryParse(word) ?? numberWords[word.toLowerCase()];

/// A date found in the text, before it's taken out.
class _DateHit {
  _DateHit(this.start, this.end, {this.date, this.horizon, this.time});

  int start;
  int end;
  final LocalDate? date;
  final WhenHorizon? horizon;

  /// "tonight" also says when in the day.
  final int? time;
}

class _Parser {
  _Parser(
    this.original, {
    required this.today,
    required this.nowMinutes,
    required this.weekStart,
    required this.dayFirst,
    required this.lists,
    required this.ignore,
  }) : s = original;

  final String original;
  final LocalDate today;
  final int nowMinutes;
  final int weekStart;
  final bool dayFirst;
  final Map<String, String> lists;
  final Set<CapturePart> ignore;

  /// The text still to be understood; found parts are blanked out.
  String s;

  LocalDate? date;
  int? time;
  WhenHorizon? horizon;
  LocalDate? deadline;
  String? listId;
  bool mustDo = false;
  String? waitingOn;
  int? effort;
  CaptureRepeat? repeat;

  void _blank(int start, int end) =>
      s = '${s.substring(0, start)} ${s.substring(end)}';

  bool _wants(CapturePart part) => !ignore.contains(part);

  ParsedCapture run() {
    if (_wants(CapturePart.effort)) _effort();
    if (_wants(CapturePart.mustDo)) _mustDo();
    if (_wants(CapturePart.waiting)) _waiting();
    if (_wants(CapturePart.list)) _list();
    if (_wants(CapturePart.repeat)) _repeat();
    if (_wants(CapturePart.deadline)) _deadline();
    if (_wants(CapturePart.when)) _when();
    if (_wants(CapturePart.time)) _time();
    _settle();

    final title = _cleanTitle(s);
    if (title.isEmpty) {
      // Nothing left to call it: keep the words as the title instead.
      return ParsedCapture(title: original.trim(), original: original);
    }
    return ParsedCapture(
      title: title,
      original: original,
      date: date,
      time: date == null ? null : time,
      horizon: date == null ? horizon : null,
      deadline: deadline,
      listId: listId,
      mustDo: mustDo,
      waitingOn: waitingOn,
      effort: effort,
      repeat: repeat,
    );
  }

  // Effort: "~15m", "~1h", "~30".

  void _effort() {
    final match = _re(
      r'(?<!\S)~\s?(\d{1,3})\s?(m|min|mins|minutes|h|hr|hrs|hour|hours)?' + _e,
    ).firstMatch(s);
    if (match == null) return;
    final n = int.parse(match[1]!);
    final unit = match[2]?.toLowerCase() ?? 'm';
    final minutes = unit.startsWith('h') ? n * 60 : n;
    if (minutes <= 0) return;
    effort = snapEffort(minutes);
    _blank(match.start, match.end);
  }

  // Must-do: a "!" on its own, or at the very end.

  void _mustDo() {
    final match =
        _re(r'(?<!\S)!{1,3}(?!\S)').firstMatch(s) ??
        _re(r'(?<=[\p{L}\p{N}\p{M}])!{1,3}\s*$').firstMatch(s);
    if (match == null) return;
    mustDo = true;
    _blank(match.start, match.end);
  }

  // Waiting on: "@priya".

  void _waiting() {
    final match = _re(
      r'(?<!\S)@([\p{L}\p{M}][\p{L}\p{N}\p{M}_.\-]*)',
    ).firstMatch(s);
    if (match == null) return;
    final name = match[1]!
        .replaceAll('_', ' ')
        .replaceAll(RegExp(r'[.\-]$'), '');
    if (name.isEmpty) return;
    waitingOn = name;
    _blank(match.start, match.end);
  }

  // List: "#errands", matched to an existing list.

  static String _key(String name) =>
      name.toLowerCase().replaceAll(RegExp(r'[\s_\-]+', unicode: true), '');

  void _list() {
    for (final match in _re(r'(?<!\S)#([\p{L}\p{N}\p{M}_\-]+)').allMatches(s)) {
      final wanted = _key(match[1]!);
      final keyed = {
        for (final MapEntry(:key, :value) in lists.entries) _key(key): value,
      };
      final id =
          keyed[wanted] ??
          keyed.entries
              .where((e) => e.key.startsWith(wanted) && wanted.length >= 2)
              .firstOrNull
              ?.value;
      if (id == null) continue;
      listId = id;
      _blank(match.start, match.end);
      return;
    }
  }

  // Repeats.

  void _repeat() {
    final every = _alt(everyWords);
    final weekdayList =
        '(?:$_weekdayAlt)(?:\\s*(?:,|and|&|\\+|और)\\s*(?:$_weekdayAlt))*';

    // "every Mon and Thu", "हर सोमवार".
    var match = _re('$_b(?:$every)\\s+($weekdayList)$_e').firstMatch(s);
    if (match != null) {
      final days = {
        for (final word in _re(_weekdayAlt).allMatches(match[1]!))
          _weekdayByWord[word[0]!.toLowerCase()]!,
      };
      repeat = CaptureRepeat(freq: RepeatFrequency.weekly, weekdays: days);
      return _blank(match.start, match.end);
    }

    // "every weekday".
    match = _re('$_b(?:${_alt(weekdaysWords)})$_e').firstMatch(s);
    if (match != null) {
      repeat = const CaptureRepeat(
        freq: RepeatFrequency.weekly,
        weekdays: {1, 2, 3, 4, 5},
      );
      return _blank(match.start, match.end);
    }

    // "every 3 days", "every other week".
    final units = _alt([...dayUnits, ...weekUnits, ...monthUnits]);
    match = _re(
      '$_b(?:$every)\\s+($_numberAlt|other)\\s+($units)$_e',
    ).firstMatch(s);
    if (match != null) {
      final n = match[1]!.toLowerCase() == 'other' ? 2 : _number(match[1]!);
      final unit = match[2]!.toLowerCase();
      if (n != null && n >= 1) {
        repeat = CaptureRepeat(freq: _unitFreq(unit), interval: n);
        return _blank(match.start, match.end);
      }
    }

    // "every 1st", "monthly on the 15th", "every month on the 3rd".
    match =
        _re('$_b(?:$every)\\s+(\\d{1,2})(?:st|nd|rd|th)$_e').firstMatch(s) ??
        _re(
          '$_b(?:${_alt(monthlyWords)})\\s+on\\s+the\\s+(\\d{1,2})$_ordinal$_e',
        ).firstMatch(s);
    if (match != null) {
      final day = int.parse(match[1]!);
      if (day >= 1 && day <= 31) {
        repeat = CaptureRepeat(freq: RepeatFrequency.monthly, monthDay: day);
        return _blank(match.start, match.end);
      }
    }

    for (final (words, rule) in [
      (dailyWords, const CaptureRepeat(freq: RepeatFrequency.daily)),
      (weeklyWords, const CaptureRepeat(freq: RepeatFrequency.weekly)),
      (monthlyWords, const CaptureRepeat(freq: RepeatFrequency.monthly)),
      (
        yearlyWords,
        const CaptureRepeat(freq: RepeatFrequency.monthly, interval: 12),
      ),
    ]) {
      final m = _re('$_b(?:${_alt(words)})$_e').firstMatch(s);
      if (m != null) {
        repeat = rule;
        return _blank(m.start, m.end);
      }
    }
  }

  static RepeatFrequency _unitFreq(String unit) => dayUnits.contains(unit)
      ? RepeatFrequency.daily
      : weekUnits.contains(unit)
      ? RepeatFrequency.weekly
      : RepeatFrequency.monthly;

  // Deadlines: "by Friday", "due 30 Nov", "शुक्रवार तक".

  void _deadline() {
    final before = _re(
      '$_b(?:${_alt(deadlineWords.where((w) => w != 'तक'))})\\s+\$',
    );
    final after = _re(r'^\s+(?:तक)' + _e);
    final hit = _findDate((hit) {
      if (hit.date == null && hit.horizon == null) return false;
      final head = before.firstMatch(s.substring(0, hit.start));
      if (head != null) {
        hit.start = head.start;
        return true;
      }
      final tail = after.firstMatch(s.substring(hit.end));
      if (tail != null) {
        hit.end += tail.end;
        return true;
      }
      return false;
    });
    if (hit == null) return;
    deadline = hit.date ?? _horizonDate(hit.horizon!);
    _blank(hit.start, hit.end);
  }

  LocalDate _horizonDate(WhenHorizon horizon) => switch (horizon) {
    WhenHorizon.today => today,
    WhenHorizon.thisWeek => today.startOfWeek(weekStart).addDays(6),
    WhenHorizon.anytime => today,
  };

  // Do-dates and horizons.

  void _when() {
    final hit = _findDate((_) => true);
    if (hit == null) return;
    date = hit.date;
    horizon = hit.horizon;
    if (hit.time != null && _wants(CapturePart.time)) time = hit.time;
    _blank(hit.start, hit.end);
  }

  /// Every date expression in [s], earliest first (and longest first at the
  /// same place); returns the first that [accept] takes.
  _DateHit? _findDate(bool Function(_DateHit hit) accept) {
    final hits = <_DateHit>[];
    void add(RegExp re, _DateHit? Function(RegExpMatch m) resolve) {
      for (final m in re.allMatches(s)) {
        if (resolve(m) case final hit?) hits.add(hit);
      }
    }

    // "today", "tomorrow", "कल", "day after tomorrow".
    add(_re('$_b(${_alt(relativeDayWords.keys)})$_e'), (m) {
      final word = m[1]!.toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
      final days = relativeDayWords[word]!;
      final tonight = word == 'tonight' || word == 'आज रात';
      return _DateHit(
        m.start,
        m.end,
        horizon: days == 0 && !tonight ? WhenHorizon.today : null,
        date: days == 0 && !tonight ? null : today.addDays(days),
        time: tonight ? timeOfDayWords['tonight'] : null,
      );
    });

    // "this week" (a horizon), "next week", "next month", weekends.
    add(_re('$_b(?:${_alt(thisWeekWords)})$_e'), (m) {
      return _DateHit(m.start, m.end, horizon: WhenHorizon.thisWeek);
    });
    add(_re('$_b(?:${_alt(nextWeekWords)})$_e'), (m) {
      final next = today.startOfWeek(weekStart).addDays(7);
      return _DateHit(m.start, m.end, date: next);
    });
    add(_re('$_b(?:${_alt(nextMonthWords)})$_e'), (m) {
      final next = LocalDate(today.year, today.month + 1, 1);
      return _DateHit(m.start, m.end, date: next);
    });
    add(_re('$_b(?:${_alt(nextWeekendWords)})$_e'), (m) {
      return _DateHit(m.start, m.end, date: _saturday().addDays(7));
    });
    add(_re('$_b(?:${_alt(weekendWords)})$_e'), (m) {
      return _DateHit(m.start, m.end, date: _saturday());
    });

    // "in 3 days", "in a week", "3 दिन में".
    final units = _alt([...dayUnits, ...weekUnits, ...monthUnits]);
    add(_re('$_b(?:${_alt(inWords)})\\s+($_numberAlt)\\s+($units)$_e'), (m) {
      return _inSpan(m.start, m.end, m[1]!, m[2]!);
    });
    add(
      _re('$_b($_numberAlt)\\s+($units)\\s+(?:${_alt(afterInWords)})$_e'),
      (m) => _inSpan(m.start, m.end, m[1]!, m[2]!),
    );

    // "12 Nov", "12th of November", "15 नवंबर".
    add(
      _re(
        '$_b(\\d{1,2})$_ordinal\\s*(?:of\\s+)?($_monthAlt)$_e(?:\\s*,?\\s*(\\d{4})$_e)?',
      ),
      (m) => _explicit(m.start, m.end, int.parse(m[1]!), m[2]!, m[3]),
    );
    // "Nov 12", "November 12th".
    add(
      _re(
        '$_b($_monthAlt)\\s+(\\d{1,2})$_ordinal$_e(?:\\s*,?\\s*(\\d{4})$_e)?',
      ),
      (m) => _explicit(m.start, m.end, int.parse(m[2]!), m[1]!, m[3]),
    );
    // "12/11", "12/11/2026", "12-11", "12.11".
    add(
      _re(
        r'(?<![\d/.\-])(\d{1,2})[/.\-](\d{1,2})(?:[/.\-](\d{2}|\d{4}))?(?![\d/.\-])'
        r'(?!\s*(?:kg|g|gm|l|ml|cup|cups|litres?|liters?|cm|mm|m|inch|inches|%))',
      ),
      (m) {
        final a = int.parse(m[1]!);
        final b = int.parse(m[2]!);
        final (day, month) = dayFirst ? (a, b) : (b, a);
        return _numeric(m.start, m.end, day, month, m[3]);
      },
    );
    // "the 15th", "on the 1st", "15 तारीख".
    add(_re('$_b(?:on\\s+)?the\\s+(\\d{1,2})(?:st|nd|rd|th)$_e'), (m) {
      return _dayOfMonth(m.start, m.end, int.parse(m[1]!));
    });
    add(_re('$_b(\\d{1,2})\\s+तारीख(?:\\s+को)?$_e'), (m) {
      return _dayOfMonth(m.start, m.end, int.parse(m[1]!));
    });

    // "Friday", "on fri", "next Friday", "अगले शुक्रवार".
    add(
      _re(
        '$_b(?:(${_alt([...nextWords, ...thisWords, 'by', 'due'])})\\s+)?'
        '($_weekdayAlt)$_e',
      ),
      (m) {
        final word = m[2]!.toLowerCase();
        final prefix = m[1]?.toLowerCase();
        final atEnd = s.substring(m.end).trim().isEmpty;
        if (ambiguousWeekdays.contains(word) && prefix == null && !atEnd) {
          return null;
        }
        final weekday = _weekdayByWord[word]!;
        final next = prefix != null && nextWords.contains(prefix);
        // "by"/"due" stay in the text for the deadline to find.
        final keepPrefix = prefix == 'by' || prefix == 'due';
        final start = keepPrefix ? m.start + m[0]!.indexOf(m[2]!) : m.start;
        return _DateHit(start, m.end, date: _weekday(weekday, next: next));
      },
    );

    hits.sort((a, b) {
      final byStart = a.start.compareTo(b.start);
      return byStart != 0 ? byStart : (b.end - b.start) - (a.end - a.start);
    });
    for (final hit in hits) {
      if (accept(hit)) return hit;
    }
    return null;
  }

  _DateHit? _inSpan(int start, int end, String count, String unit) {
    final n = _number(count);
    if (n == null || n < 0 || n > 999) return null;
    final u = unit.toLowerCase();
    final date = dayUnits.contains(u)
        ? today.addDays(n)
        : weekUnits.contains(u)
        ? today.addDays(7 * n)
        : today.addMonths(n);
    return _DateHit(start, end, date: date);
  }

  _DateHit? _explicit(int start, int end, int day, String month, String? year) {
    final m = _monthByWord[month.toLowerCase()];
    if (m == null) return null;
    return _numeric(start, end, day, m, year);
  }

  _DateHit? _numeric(int start, int end, int day, int month, String? year) {
    if (month < 1 || month > 12 || day < 1) return null;
    var y = year == null
        ? today.year
        : (year.length == 2 ? 2000 + int.parse(year) : int.parse(year));
    if (day > LocalDate(y, month, 1).daysInMonth) return null;
    var date = LocalDate(y, month, day);
    if (year == null && date.isBefore(today)) {
      y++;
      if (day > LocalDate(y, month, 1).daysInMonth) return null;
      date = LocalDate(y, month, day);
    }
    return _DateHit(start, end, date: date);
  }

  _DateHit? _dayOfMonth(int start, int end, int day) {
    if (day < 1 || day > 31) return null;
    return _DateHit(start, end, date: _nextMonthDay(day));
  }

  /// The next date on or after today that falls on day [day] of a month
  /// (clamped to shorter months).
  LocalDate _nextMonthDay(int day) {
    for (var k = 0; k < 13; k++) {
      final first = LocalDate(today.year, today.month + k, 1);
      final date = LocalDate(
        first.year,
        first.month,
        min(day, first.daysInMonth),
      );
      if (!date.isBefore(today)) return date;
    }
    return today;
  }

  /// The coming [weekday] (today counts); with [next], the one in next week.
  LocalDate _weekday(int weekday, {required bool next}) {
    if (next) {
      final nextWeek = today.startOfWeek(weekStart).addDays(7);
      return nextWeek.addDays((weekday - nextWeek.weekday) % 7);
    }
    return today.addDays((weekday - today.weekday) % 7);
  }

  /// The coming Saturday, or today at the weekend.
  LocalDate _saturday() {
    if (today.weekday == DateTime.sunday) return today;
    return today.addDays((DateTime.saturday - today.weekday) % 7);
  }

  // Times.

  void _time() {
    int? h24(int hour, int minute, {String? meridiem, String? partOfDay}) {
      if (minute < 0 || minute > 59) return null;
      var h = hour;
      if (meridiem != null) {
        if (h < 1 || h > 12) return null;
        final pm = meridiem.toLowerCase().startsWith('p');
        h = h % 12 + (pm ? 12 : 0);
      } else if (partOfDay != null) {
        if (h < 1 || h > 12) return null;
        final morning = hindiMorning.contains(partOfDay.toLowerCase());
        if (!morning && h < 12) h += 12;
        if (morning && h == 12) h = 0;
      } else {
        if (h > 23) return null;
        // "at 6" means the evening; "at 9" the morning.
        if (h >= 1 && h <= 7) h += 12;
      }
      return h * 60 + minute;
    }

    final partAlt = _alt([...hindiMorning, ...hindiAfternoonEvening]);
    final candidates = <(RegExp, int? Function(RegExpMatch))>[
      // "9am", "9:30 pm", "at 9 a.m.".
      (
        _re(
          '$_b(?:(?:at|around)\\s+)?(\\d{1,2})(?:[:.](\\d{2}))?\\s*'
          r'(am|pm|a\.m\.|p\.m\.)(?![\p{L}\p{N}])',
        ),
        (m) => h24(int.parse(m[1]!), int.parse(m[2] ?? '0'), meridiem: m[3]!),
      ),
      // "सुबह 9 बजे", "6 बजे".
      (
        _re(
          '$_b(?:($partAlt)\\s+)?(\\d{1,2})(?::(\\d{2}))?\\s*(?:${_alt(oClockWords)})$_e',
        ),
        (m) => h24(int.parse(m[2]!), int.parse(m[3] ?? '0'), partOfDay: m[1]),
      ),
      // "14:30", "at 9", "at 6:15".
      (
        _re(r'(?<![\d/.:])(\d{1,2}):(\d{2})(?![\d/.:])'),
        (m) {
          final h = int.parse(m[1]!);
          if (h > 23) return null;
          return h * 60 + int.parse(m[2]!);
        },
      ),
      (
        _re('$_b(?:at|around)\\s+(\\d{1,2})(?:[:.](\\d{2}))?(?![\\d/.:])$_e'),
        (m) => h24(int.parse(m[1]!), int.parse(m[2] ?? '0')),
      ),
      // "noon", "this evening", and "morning" when a day was given.
      (
        _re(
          '$_b(${_alt(timeOfDayWords.keys.where((w) => date != null || horizon != null || w.contains(' ') || w == 'noon' || w == 'midday' || w == 'tonight'))})$_e',
        ),
        (m) =>
            timeOfDayWords[m[1]!.toLowerCase().replaceAll(RegExp(r'\s+'), ' ')],
      ),
    ];
    for (final (re, resolve) in candidates) {
      for (final m in re.allMatches(s)) {
        final minutes = resolve(m);
        if (minutes == null) continue;
        time = minutes;
        _blank(m.start, m.end);
        return;
      }
    }
  }

  /// A time needs a day: Today, or tomorrow once today's time has passed.
  /// A repeat needs a first date.
  void _settle() {
    if (time != null && date == null) {
      if (horizon == WhenHorizon.thisWeek) {
        time = null;
      } else {
        date = horizon == WhenHorizon.today || time! > nowMinutes
            ? today
            : today.addDays(1);
        horizon = null;
      }
    }
    if (repeat case final rule?) {
      if (date == null || date!.isBefore(today)) {
        date = switch (rule) {
          CaptureRepeat(weekdays: final days) when days.isNotEmpty =>
            today.addDays(days.map((d) => (d - today.weekday) % 7).reduce(min)),
          CaptureRepeat(monthDay: final day?) => _nextMonthDay(day),
          _ => today,
        };
      }
      horizon = null;
    }
  }

  String _cleanTitle(String text) {
    final words = text
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    bool punct(String w) => RegExp(r'^[,;:\-–—·.]+$').hasMatch(w);
    bool dangling(String w) =>
        danglingWords.contains(w.toLowerCase()) || punct(w);
    while (words.isNotEmpty && dangling(words.last)) {
      words.removeLast();
    }
    while (words.isNotEmpty && dangling(words.first)) {
      words.removeAt(0);
    }
    var title = words.join(' ');
    title = title.replaceAll(RegExp(r'^[,;:\-–—\s]+|[,;:\-–—\s]+$'), '');
    if (title.isEmpty) return title;
    // Keep a capital first letter if the line began with one.
    final first = original.trimLeft();
    if (first.isNotEmpty && first[0] != first[0].toLowerCase()) {
      title = title[0].toUpperCase() + title.substring(1);
    }
    return title;
  }
}
