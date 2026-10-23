import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/providers.dart';
import '../../domain/calendar_rules.dart';
import '../../domain/item.dart';
import '../../domain/local_date.dart';
import '../../l10n/l10n.dart';
import '../format.dart';

final _occurrencesProvider = StreamProvider.autoDispose
    .family<List<Item>, String>(
      (ref, seriesId) =>
          ref.watch(seriesRepositoryProvider).watchOccurrences(seriesId),
    );

/// A repeating item's dates, a month at a time (FR-15): what was done,
/// skipped, is open now, and is still to come. Marks use shapes as well as
/// colour (FR-20).
class SeriesCalendarScreen extends ConsumerStatefulWidget {
  const SeriesCalendarScreen({super.key, required this.seriesId});

  final String seriesId;

  @override
  ConsumerState<SeriesCalendarScreen> createState() =>
      _SeriesCalendarScreenState();
}

class _SeriesCalendarScreenState extends ConsumerState<SeriesCalendarScreen> {
  LocalDate? _month;

  (IconData, String) _look(OccurrenceMark mark) => switch (mark) {
    OccurrenceMark.done => (
      Icons.check_circle,
      context.l10n.seriesCalendarDone,
    ),
    OccurrenceMark.skipped => (
      Icons.remove_circle_outline,
      context.l10n.seriesCalendarSkipped,
    ),
    OccurrenceMark.open => (
      Icons.radio_button_unchecked,
      context.l10n.seriesCalendarOpenNow,
    ),
    OccurrenceMark.planned => (
      Icons.circle,
      context.l10n.seriesCalendarComingUp,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final today =
        ref.watch(todayProvider).value ??
        LocalDate.fromDateTime(DateTime.now());
    final month = _month ?? LocalDate(today.year, today.month, 1);
    final series = ref.watch(seriesProvider(widget.seriesId)).value;
    final occurrences =
        ref.watch(_occurrencesProvider(widget.seriesId)).value ?? const [];
    final weekStart =
        ref.watch(settingsProvider).value?.weekStart ?? DateTime.monday;
    if (series == null) return const Scaffold();

    final marks = seriesCalendar(
      series,
      occurrences,
      month: month,
      today: today,
    );
    final first = month;
    final lead = (first.weekday - weekStart) % 7;
    final cells = [
      for (var i = 0; i < lead; i++) null,
      for (var d = 1; d <= first.daysInMonth; d++)
        LocalDate(month.year, month.month, d),
    ];
    final title = DateFormat('MMMM y').format(dateTimeOf(month));

    Color colorOf(OccurrenceMark mark) => switch (mark) {
      OccurrenceMark.done => scheme.primary,
      OccurrenceMark.planned => scheme.outline,
      _ => scheme.onSurfaceVariant,
    };

    return Scaffold(
      appBar: AppBar(title: Text(series.template.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 32),
        children: [
          Text(
            describeRepeat(series, today),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                tooltip: context.l10n.seriesCalendarPreviousMonth,
                onPressed: () => setState(() => _month = month.addMonths(-1)),
              ),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                tooltip: context.l10n.seriesCalendarNextMonth,
                onPressed: () => setState(() => _month = month.addMonths(1)),
              ),
            ],
          ),
          ExcludeSemantics(
            child: Row(
              children: [
                for (final day in weekdaysFrom(weekStart))
                  Expanded(
                    child: Text(
                      weekdayShort(day),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelMedium,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.8,
            children: [
              for (final day in cells)
                if (day == null)
                  const SizedBox.shrink()
                else
                  Semantics(
                    label: [
                      DateFormat('d MMMM').format(dateTimeOf(day)),
                      if (marks[day] case final mark?) _look(mark).$2,
                      if (day == today) context.l10n.seriesCalendarToday,
                    ].join(', '),
                    excludeSemantics: true,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${day.day}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: day == today ? FontWeight.bold : null,
                            decoration: day == today
                                ? TextDecoration.underline
                                : null,
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (marks[day] case final mark?)
                          Icon(
                            _look(mark).$1,
                            size: mark == OccurrenceMark.planned ? 8 : 16,
                            color: colorOf(mark),
                          )
                        else
                          const SizedBox(height: 16),
                      ],
                    ),
                  ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (final mark in OccurrenceMark.values)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_look(mark).$1, size: 16, color: colorOf(mark)),
                    const SizedBox(width: 4),
                    Text(_look(mark).$2),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
