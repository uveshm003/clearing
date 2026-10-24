import 'package:clearing/domain/capture_parser.dart';
import 'package:clearing/domain/enums.dart';
import 'package:clearing/domain/local_date.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wednesday 21 October 2026, 10:00.
final today = LocalDate(2026, 10, 21);
const now = 10 * 60;
const lists = {'Errands': 'errands', 'Life Admin': 'admin', 'Home': 'home'};

ParsedCapture parse(
  String text, {
  Set<CapturePart> ignore = const {},
  bool dayFirst = true,
}) => parseCapture(
  text,
  today: today,
  nowMinutes: now,
  lists: lists,
  ignore: ignore,
  dayFirst: dayFirst,
);

LocalDate d(int month, int day, [int year = 2026]) =>
    LocalDate(year, month, day);

void main() {
  group('relative days', () {
    final cases = <(String, String, LocalDate?, WhenHorizon?)>[
      ('Call mum today', 'Call mum', null, WhenHorizon.today),
      ('call mum tomorrow', 'call mum', d(10, 22), null),
      ('Buy milk tmrw', 'Buy milk', d(10, 22), null),
      ('Pay rent day after tomorrow', 'Pay rent', d(10, 23), null),
      ('Book flights this week', 'Book flights', null, WhenHorizon.thisWeek),
      ('Plan trip next week', 'Plan trip', d(10, 26), null),
      ('Clean garage this weekend', 'Clean garage', d(10, 24), null),
      ('Garden next weekend', 'Garden', d(10, 31), null),
      ('Renew licence next month', 'Renew licence', d(11, 1), null),
      ('Email Sam in 3 days', 'Email Sam', d(10, 24), null),
      ('Check results in a week', 'Check results', d(10, 28), null),
      ('Dentist in two weeks', 'Dentist', d(11, 4), null),
      ('Service the car in 2 months', 'Service the car', d(12, 21), null),
    ];
    for (final (text, title, date, horizon) in cases) {
      test(text, () {
        final p = parse(text);
        expect(p.title, title);
        expect(p.date, date);
        expect(p.horizon, horizon);
      });
    }
  });

  group('weekdays', () {
    final cases = <(String, String, LocalDate)>[
      ('Pay rent friday', 'Pay rent', d(10, 23)),
      ('Pay rent on fri', 'Pay rent', d(10, 23)),
      ('Team lunch Wednesday', 'Team lunch', d(10, 21)),
      ('Call Ana next Monday', 'Call Ana', d(10, 26)),
      ('Call Ana next fri', 'Call Ana', d(10, 30)),
      ('Market on sat', 'Market', d(10, 24)),
      ('Market sat', 'Market', d(10, 24)),
      ('Tue: dentist', 'Dentist', d(10, 27)),
    ];
    for (final (text, title, date) in cases) {
      test(text, () {
        final p = parse(text);
        expect(p.title, title);
        expect(p.date, date);
      });
    }

    test('ambiguous short forms stay words mid-sentence', () {
      expect(parse('Buy sun cream').date, isNull);
      expect(parse('Buy sun cream').title, 'Buy sun cream');
      expect(parse('Sat down with Raj notes').date, isNull);
      expect(parse('Wed photos to print').date, isNull);
    });
  });

  group('explicit dates', () {
    final cases = <(String, String, LocalDate)>[
      ('Renew passport 12 nov', 'Renew passport', d(11, 12)),
      ('Renew passport 12th of November', 'Renew passport', d(11, 12)),
      ('Renew passport Nov 12', 'Renew passport', d(11, 12)),
      ('Renew passport November 12th, 2027', 'Renew passport', d(11, 12, 2027)),
      ('Tax return 31/1', 'Tax return', d(1, 31, 2027)),
      ('Tax return 31/01/2027', 'Tax return', d(1, 31, 2027)),
      ('Pay rent on the 1st', 'Pay rent', d(11, 1)),
      ('Pay rent the 25th', 'Pay rent', d(10, 25)),
      ('Birthday 3 march', 'Birthday', d(3, 3, 2027)),
    ];
    for (final (text, title, date) in cases) {
      test(text, () {
        final p = parse(text);
        expect(p.title, title);
        expect(p.date, date);
      });
    }

    test('month-first when the locale reads dates that way', () {
      expect(parse('Party 11/5', dayFirst: false).date, d(11, 5));
      expect(parse('Party 11/5').date, d(5, 11, 2027));
    });

    test('month words alone are not dates', () {
      final p = parse('Call May about the march');
      expect(p.date, isNull);
      expect(p.title, 'Call May about the march');
    });

    test('quantities are not dates', () {
      expect(parse('Buy 1/2 kg rice').date, isNull);
      expect(parse('Buy 1/2 kg rice').title, 'Buy 1/2 kg rice');
    });

    test('impossible dates are left alone', () {
      expect(parse('Code 31/2').date, isNull);
      expect(parse('Room 45/7').date, isNull);
    });
  });

  group('times', () {
    final cases = <(String, String, LocalDate, int)>[
      ('Pay rent fri 9am', 'Pay rent', d(10, 23), 9 * 60),
      ('Call at 6', 'Call', d(10, 21), 18 * 60),
      ('Call at 9', 'Call', d(10, 22), 9 * 60),
      ('Standup 14:30', 'Standup', d(10, 21), 14 * 60 + 30),
      ('Lunch tomorrow at noon', 'Lunch', d(10, 22), 12 * 60),
      ('Dinner 7:30 pm friday', 'Dinner', d(10, 23), 19 * 60 + 30),
      ('Movie tonight', 'Movie', d(10, 21), 20 * 60),
      ('Run tomorrow morning', 'Run', d(10, 22), 9 * 60),
      ('Meds today 8am', 'Meds', d(10, 21), 8 * 60),
    ];
    for (final (text, title, date, time) in cases) {
      test(text, () {
        final p = parse(text);
        expect(p.title, title);
        expect(p.date, date);
        expect(p.time, time);
      });
    }

    test('a time alone that has passed today means tomorrow', () {
      final p = parse('Water plants 9am');
      expect(p.date, d(10, 22));
      expect(p.time, 9 * 60);
    });

    test('"morning" alone is part of the title', () {
      final p = parse('Morning pages');
      expect(p.time, isNull);
      expect(p.title, 'Morning pages');
    });
  });

  group('deadlines', () {
    test('by a weekday', () {
      final p = parse('Send report by friday');
      expect(p.title, 'Send report');
      expect(p.deadline, d(10, 23));
      expect(p.date, isNull);
    });

    test('due a date, with a separate do-date', () {
      final p = parse('Start essay tomorrow due 30 nov');
      expect(p.title, 'Start essay');
      expect(p.date, d(10, 22));
      expect(p.deadline, d(11, 30));
    });
  });

  group('repeats', () {
    test('every Monday', () {
      final p = parse('Bins out every monday');
      expect(p.title, 'Bins out');
      expect(
        p.repeat,
        const CaptureRepeat(freq: RepeatFrequency.weekly, weekdays: {1}),
      );
      expect(p.date, d(10, 26));
    });

    test('every Mon and Thu', () {
      final p = parse('Gym every mon and thu');
      expect(
        p.repeat,
        const CaptureRepeat(freq: RepeatFrequency.weekly, weekdays: {1, 4}),
      );
      expect(p.date, d(10, 22));
    });

    test('daily, at a time', () {
      final p = parse('Take vitamins daily 8am');
      expect(p.title, 'Take vitamins');
      expect(p.repeat, const CaptureRepeat(freq: RepeatFrequency.daily));
      expect(p.time, 8 * 60);
      expect(p.date, d(10, 22));
    });

    test('monthly on the 1st, with a reminder day', () {
      final p = parse('Pay rent every 1st');
      expect(
        p.repeat,
        const CaptureRepeat(freq: RepeatFrequency.monthly, monthDay: 1),
      );
      expect(p.date, d(11, 1));
    });

    test('every 2 weeks', () {
      final p = parse('Haircut every 6 weeks');
      expect(
        p.repeat,
        const CaptureRepeat(freq: RepeatFrequency.weekly, interval: 6),
      );
      expect(p.date, today);
    });

    test('every weekday and yearly', () {
      expect(
        parse('Standup every weekday').repeat,
        const CaptureRepeat(
          freq: RepeatFrequency.weekly,
          weekdays: {1, 2, 3, 4, 5},
        ),
      );
      expect(
        parse('Insurance yearly').repeat,
        const CaptureRepeat(freq: RepeatFrequency.monthly, interval: 12),
      );
    });
  });

  group('lists, flags, people and effort', () {
    test('everything at once', () {
      final p = parse('pay rent fri 9am #home !');
      expect(p.title, 'pay rent');
      expect(p.date, d(10, 23));
      expect(p.time, 9 * 60);
      expect(p.listId, 'home');
      expect(p.mustDo, isTrue);
    });

    test('list names match loosely', () {
      expect(parse('Stamps #errands').listId, 'errands');
      expect(parse('Stamps #err').listId, 'errands');
      expect(parse('Form #life_admin').listId, 'admin');
      expect(parse('Form #lifeadmin').listId, 'admin');
    });

    test('an unknown list stays in the title', () {
      final p = parse('Read #books');
      expect(p.listId, isNull);
      expect(p.title, 'Read #books');
    });

    test('a trailing ! is a must-do; one inside a word is not', () {
      expect(parse('Call the bank!').mustDo, isTrue);
      expect(parse('Call the bank!').title, 'Call the bank');
      expect(parse('Watch Wow!Fest').mustDo, isFalse);
    });

    test('@person is waiting on them', () {
      final p = parse('Quote for the roof @priya');
      expect(p.waitingOn, 'priya');
      expect(p.title, 'Quote for the roof');
      expect(parse('Email sam@example.com').waitingOn, isNull);
    });

    test('effort snaps to the offered steps', () {
      expect(parse('Tidy desk ~10m').effort, 15);
      expect(parse('Tidy desk ~5').effort, 5);
      expect(parse('Tax ~2h').effort, 120);
      expect(parse('Tax ~45 min').effort, 60);
      expect(parse('Tidy desk ~10m').title, 'Tidy desk');
    });
  });

  group('Hindi', () {
    test('कल and a time of day', () {
      final p = parse('कल सुबह 9 बजे दूध लाना');
      expect(p.title, 'दूध लाना');
      expect(p.date, d(10, 22));
      expect(p.time, 9 * 60);
    });

    test('a weekday with को', () {
      final p = parse('शुक्रवार को किराया देना');
      expect(p.title, 'किराया देना');
      expect(p.date, d(10, 23));
    });

    test('शाम 6 बजे', () {
      final p = parse('माँ को फ़ोन शाम 6 बजे');
      expect(p.time, 18 * 60);
      expect(p.title, 'माँ को फ़ोन');
    });

    test('आज is Today; परसों two days on', () {
      expect(parse('आज बिल भरना').horizon, WhenHorizon.today);
      expect(parse('परसों डॉक्टर').date, d(10, 23));
    });

    test('dates, spans and deadlines', () {
      expect(parse('पासपोर्ट 12 नवंबर').date, d(11, 12));
      expect(parse('रिपोर्ट 3 दिन में').date, d(10, 24));
      final p = parse('रिपोर्ट शुक्रवार तक');
      expect(p.deadline, d(10, 23));
      expect(p.title, 'रिपोर्ट');
    });

    test('repeats', () {
      expect(
        parse('दवा रोज़').repeat,
        const CaptureRepeat(freq: RepeatFrequency.daily),
      );
      expect(
        parse('कचरा हर सोमवार').repeat,
        const CaptureRepeat(freq: RepeatFrequency.weekly, weekdays: {1}),
      );
      expect(
        parse('किराया हर महीने').repeat,
        const CaptureRepeat(freq: RepeatFrequency.monthly),
      );
    });

    test('romanised words', () {
      expect(parse('doodh lana kal').date, d(10, 22));
      expect(parse('bill aaj').horizon, WhenHorizon.today);
    });
  });

  group('chips and edge cases', () {
    test('an ignored part stays in the title', () {
      final p = parse('Call Friday about the boat', ignore: {CapturePart.when});
      expect(p.date, isNull);
      expect(p.title, 'Call Friday about the boat');
    });

    test('nothing understood: plain', () {
      final p = parse('Buy stamps');
      expect(p.isPlain, isTrue);
      expect(p.title, 'Buy stamps');
    });

    test('only a date: the words become the title', () {
      final p = parse('tomorrow');
      expect(p.isPlain, isTrue);
      expect(p.title, 'tomorrow');
    });

    test("words containing date words aren't dates", () {
      expect(parse("Today's newspaper").horizon, isNull);
      expect(parse('Monday.com invoice').date, isNull);
      expect(parse('Monsoon prep').date, isNull);
      expect(parse('Kalpana birthday').date, isNull);
    });

    test('a capital first letter survives', () {
      expect(parse('Tomorrow call mum').title, 'Call mum');
      expect(parse('tomorrow call mum').title, 'call mum');
    });

    test('dangling prepositions go', () {
      expect(parse('Pay rent on the 1st').title, 'Pay rent');
      expect(parse('Meet Jo at 3pm').title, 'Meet Jo');
      expect(parse('Dentist - friday').title, 'Dentist');
    });

    test('hasPlan', () {
      expect(parse('Milk tomorrow').hasPlan, isTrue);
      expect(parse('Milk #errands').hasPlan, isFalse);
      expect(parse('Milk !').hasPlan, isTrue);
    });
  });
}
