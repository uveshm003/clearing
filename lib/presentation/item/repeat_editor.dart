import 'package:flutter/material.dart' hide RepeatMode;

import '../../domain/enums.dart';
import '../../domain/local_date.dart';
import '../../domain/repeat_series.dart';
import '../../l10n/l10n.dart';
import '../format.dart';
import '../widgets/choice_sheet.dart';
import '../widgets/section_header.dart';
import '../widgets/when_sheet.dart';

/// Opens the repeat editor (FR-10) and returns the edited series, or null if
/// cancelled.
Future<RepeatSeries?> editRepeat(
  BuildContext context, {
  required RepeatSeries initial,
  required LocalDate today,
  int weekStart = DateTime.monday,
}) => Navigator.of(context).push(
  MaterialPageRoute(
    fullscreenDialog: true,
    builder: (_) =>
        RepeatEditor(initial: initial, today: today, weekStart: weekStart),
  ),
);

enum _Ends { never, onDate, afterCount }

class RepeatEditor extends StatefulWidget {
  const RepeatEditor({
    super.key,
    required this.initial,
    required this.today,
    this.weekStart = DateTime.monday,
  });

  final RepeatSeries initial;
  final LocalDate today;

  /// Weekday chips start on this day (FR-21).
  final int weekStart;

  @override
  State<RepeatEditor> createState() => _RepeatEditorState();
}

class _RepeatEditorState extends State<RepeatEditor> {
  late RepeatSeries _series = widget.initial.copyWith(
    weekdays: widget.initial.weekdays.isEmpty
        ? {widget.initial.startDate.weekday}
        : null,
  );
  late _Ends _ends = switch (widget.initial) {
    RepeatSeries(endDate: _?) => _Ends.onDate,
    RepeatSeries(maxCount: _?) => _Ends.afterCount,
    _ => _Ends.never,
  };

  void _update(RepeatSeries series) => setState(() => _series = series);

  String get _every => switch (_series.freq) {
    RepeatFrequency.daily => context.l10n.repeatEveryDays(_series.interval),
    RepeatFrequency.weekly => context.l10n.repeatEveryWeeks(_series.interval),
    RepeatFrequency.monthly => context.l10n.repeatEveryMonths(_series.interval),
  };

  Future<void> _setEnds(_Ends ends) async {
    switch (ends) {
      case _Ends.never:
        _update(_series.copyWith(endDate: () => null, maxCount: () => null));
      case _Ends.onDate:
        final picked = await pickDate(
          context,
          today: widget.today,
          initial: _series.endDate ?? widget.today.addDays(30),
          askTime: false,
        );
        if (picked == null) return;
        _update(
          _series.copyWith(endDate: () => picked.date, maxCount: () => null),
        );
      case _Ends.afterCount:
        _update(
          _series.copyWith(
            endDate: () => null,
            maxCount: () => _series.maxCount ?? 10,
          ),
        );
    }
    setState(() => _ends = ends);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final series = _series;
    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        title: Text(context.l10n.repeatTitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, series),
            child: Text(context.l10n.commonSave),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          // The rule in words, updated as it changes.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              describeRepeat(series, widget.today),
              style: theme.textTheme.titleMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SegmentedButton<RepeatFrequency>(
              segments: [
                ButtonSegment(
                  value: RepeatFrequency.daily,
                  label: Text(context.l10n.repeatDaily),
                ),
                ButtonSegment(
                  value: RepeatFrequency.weekly,
                  label: Text(context.l10n.repeatWeekly),
                ),
                ButtonSegment(
                  value: RepeatFrequency.monthly,
                  label: Text(context.l10n.repeatMonthly),
                ),
              ],
              selected: {series.freq},
              onSelectionChanged: (s) =>
                  _update(series.copyWith(freq: s.single)),
            ),
          ),
          ListTile(
            title: Text(_every),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  tooltip: context.l10n.repeatLessOften,
                  onPressed: series.interval > 1
                      ? () => _update(
                          series.copyWith(interval: series.interval - 1),
                        )
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: context.l10n.repeatMoreSpreadOut,
                  onPressed: series.interval < 99
                      ? () => _update(
                          series.copyWith(interval: series.interval + 1),
                        )
                      : null,
                ),
              ],
            ),
          ),
          SwitchListTile(
            title: Text(context.l10n.repeatAfterCompletionTitle),
            subtitle: Text(context.l10n.repeatAfterCompletionSubtitle),
            value: series.isAfterCompletion,
            onChanged: (on) => _update(
              series.copyWith(
                mode: on ? RepeatMode.afterCompletion : RepeatMode.fixed,
              ),
            ),
          ),
          if (series.freq == RepeatFrequency.weekly &&
              !series.isAfterCompletion)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final day in weekdaysFrom(widget.weekStart))
                    FilterChip(
                      label: Text(weekdayShort(day)),
                      selected: series.weekdays.contains(day),
                      // At least one day stays selected.
                      onSelected:
                          series.weekdays.length == 1 &&
                              series.weekdays.contains(day)
                          ? null
                          : (on) => _update(
                              series.copyWith(
                                weekdays: on
                                    ? {...series.weekdays, day}
                                    : ({...series.weekdays}..remove(day)),
                              ),
                            ),
                    ),
                ],
              ),
            ),
          if (series.freq == RepeatFrequency.monthly &&
              !series.isAfterCompletion)
            ChoiceTile<int>(
              title: context.l10n.repeatOnDay,
              hint: context.l10n.repeatOnDayHint,
              value: series.monthDay ?? series.startDate.day,
              options: [
                for (var day = 1; day <= 31; day++) (day, ordinal(day)),
              ],
              onChanged: (day) => _update(series.copyWith(monthDay: () => day)),
            ),
          ListTile(
            title: Text(context.l10n.repeatStarts),
            trailing: Text(dateLabel(series.startDate, widget.today)),
          ),
          SectionHeader(context.l10n.repeatEnds),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<_Ends>(
              segments: [
                ButtonSegment(
                  value: _Ends.never,
                  label: Text(context.l10n.repeatEndsNever),
                ),
                ButtonSegment(
                  value: _Ends.onDate,
                  label: Text(context.l10n.repeatEndsOnDate),
                ),
                ButtonSegment(
                  value: _Ends.afterCount,
                  label: Text(context.l10n.repeatEndsAfter),
                ),
              ],
              selected: {_ends},
              onSelectionChanged: (s) => _setEnds(s.single),
            ),
          ),
          if (series.endDate case final end?)
            ListTile(
              title: Text(
                context.l10n.repeatLastTimeOn(dateLabel(end, widget.today)),
              ),
              trailing: const Icon(Icons.edit_calendar_outlined),
              onTap: () => _setEnds(_Ends.onDate),
            ),
          if (series.maxCount case final count?)
            ListTile(
              title: Text(context.l10n.repeatTimesInAll(count)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    tooltip: context.l10n.repeatFewerTimes,
                    onPressed: count > 1
                        ? () => _update(
                            series.copyWith(maxCount: () => count - 1),
                          )
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: context.l10n.repeatMoreTimes,
                    onPressed: () =>
                        _update(series.copyWith(maxCount: () => count + 1)),
                  ),
                ],
              ),
            ),
          if (!series.isAfterCompletion) ...[
            SectionHeader(context.l10n.repeatIfMissed),
            RadioGroup<OnMissed>(
              groupValue: series.onMissed,
              onChanged: (v) => _update(series.copyWith(onMissed: v)),
              child: Column(
                children: [
                  RadioListTile(
                    value: OnMissed.carryOver,
                    title: Text(context.l10n.repeatCarryOver),
                    subtitle: Text(context.l10n.repeatCarryOverSubtitle),
                  ),
                  RadioListTile(
                    value: OnMissed.skip,
                    title: Text(context.l10n.repeatSkipQuietly),
                    subtitle: Text(context.l10n.repeatSkipQuietlySubtitle),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
