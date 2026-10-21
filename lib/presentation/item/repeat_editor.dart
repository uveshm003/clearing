import 'package:flutter/material.dart';

import '../../domain/enums.dart';
import '../../domain/local_date.dart';
import '../../domain/repeat_series.dart';
import '../format.dart';
import '../widgets/section_header.dart';
import '../widgets/when_sheet.dart';

/// Opens the repeat editor (FR-10) and returns the edited series, or null if
/// cancelled.
Future<RepeatSeries?> editRepeat(
  BuildContext context, {
  required RepeatSeries initial,
  required LocalDate today,
}) => Navigator.of(context).push(
  MaterialPageRoute(
    fullscreenDialog: true,
    builder: (_) => RepeatEditor(initial: initial, today: today),
  ),
);

enum _Ends { never, onDate, afterCount }

class RepeatEditor extends StatefulWidget {
  const RepeatEditor({super.key, required this.initial, required this.today});

  final RepeatSeries initial;
  final LocalDate today;

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

  String get _unit => switch (_series.freq) {
    RepeatFrequency.daily => _series.interval == 1 ? 'day' : 'days',
    RepeatFrequency.weekly => _series.interval == 1 ? 'week' : 'weeks',
    RepeatFrequency.monthly => _series.interval == 1 ? 'month' : 'months',
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
        title: const Text('Repeat'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, series),
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SegmentedButton<RepeatFrequency>(
              segments: const [
                ButtonSegment(
                  value: RepeatFrequency.daily,
                  label: Text('Daily'),
                ),
                ButtonSegment(
                  value: RepeatFrequency.weekly,
                  label: Text('Weekly'),
                ),
                ButtonSegment(
                  value: RepeatFrequency.monthly,
                  label: Text('Monthly'),
                ),
              ],
              selected: {series.freq},
              onSelectionChanged: (s) =>
                  _update(series.copyWith(freq: s.single)),
            ),
          ),
          ListTile(
            title: Text('Every ${series.interval} $_unit'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  tooltip: 'Less often',
                  onPressed: series.interval > 1
                      ? () => _update(
                          series.copyWith(interval: series.interval - 1),
                        )
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'More spread out',
                  onPressed: series.interval < 99
                      ? () => _update(
                          series.copyWith(interval: series.interval + 1),
                        )
                      : null,
                ),
              ],
            ),
          ),
          if (series.freq == RepeatFrequency.weekly)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var day = 1; day <= 7; day++)
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
          if (series.freq == RepeatFrequency.monthly)
            ListTile(
              title: const Text('On day'),
              subtitle: const Text('Short months use their last day'),
              trailing: DropdownButton<int>(
                value: series.monthDay ?? series.startDate.day,
                underline: const SizedBox.shrink(),
                items: [
                  for (var day = 1; day <= 31; day++)
                    DropdownMenuItem(value: day, child: Text(ordinal(day))),
                ],
                onChanged: (day) =>
                    _update(series.copyWith(monthDay: () => day)),
              ),
            ),
          ListTile(
            title: const Text('Starts'),
            trailing: Text(dateLabel(series.startDate, widget.today)),
          ),
          const SectionHeader('Ends'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<_Ends>(
              segments: const [
                ButtonSegment(value: _Ends.never, label: Text('Never')),
                ButtonSegment(value: _Ends.onDate, label: Text('On a date')),
                ButtonSegment(value: _Ends.afterCount, label: Text('After')),
              ],
              selected: {_ends},
              onSelectionChanged: (s) => _setEnds(s.single),
            ),
          ),
          if (series.endDate case final end?)
            ListTile(
              title: Text('Last time on ${dateLabel(end, widget.today)}'),
              trailing: const Icon(Icons.edit_calendar_outlined),
              onTap: () => _setEnds(_Ends.onDate),
            ),
          if (series.maxCount case final count?)
            ListTile(
              title: Text('$count times in all'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    tooltip: 'Fewer times',
                    onPressed: count > 1
                        ? () => _update(
                            series.copyWith(maxCount: () => count - 1),
                          )
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: 'More times',
                    onPressed: () =>
                        _update(series.copyWith(maxCount: () => count + 1)),
                  ),
                ],
              ),
            ),
          const SectionHeader('If one is missed'),
          RadioGroup<OnMissed>(
            groupValue: series.onMissed,
            onChanged: (v) => _update(series.copyWith(onMissed: v)),
            child: const Column(
              children: [
                RadioListTile(
                  value: OnMissed.carryOver,
                  title: Text('Carry it over'),
                  subtitle: Text(
                    'It stays on Today until done; the next one waits',
                  ),
                ),
                RadioListTile(
                  value: OnMissed.skip,
                  title: Text('Skip it quietly'),
                  subtitle: Text(
                    'Good for routines: tomorrow is a fresh start',
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: Text(
              describeRepeat(series, widget.today),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
