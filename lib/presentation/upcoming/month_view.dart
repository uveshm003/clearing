import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/glade.dart';
import '../../core/providers.dart';
import '../../domain/enums.dart';
import '../../domain/item.dart';
import '../../domain/local_date.dart';
import '../../l10n/l10n.dart';
import '../format.dart';
import '../widgets/day_rail.dart';
import '../widgets/item_tile.dart';

/// A month at a glance (§4.7): a dot for each thing planned on a day (up to
/// three, then a count), never coloured by urgency. Tap a day to see it.
class MonthView extends ConsumerStatefulWidget {
  const MonthView({super.key});

  @override
  ConsumerState<MonthView> createState() => _MonthViewState();
}

class _MonthViewState extends ConsumerState<MonthView> {
  var _offset = 0;
  LocalDate? _selected;

  @override
  Widget build(BuildContext context) {
    final today = ref.watch(todayProvider).value;
    if (today == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final glade = GladeTokens.of(context);
    final weekStart =
        ref.watch(settingsProvider).value?.weekStart ?? DateTime.monday;
    final first = LocalDate(today.year, today.month + _offset, 1);
    final gridStart = first.startOfWeek(weekStart);
    final weeks = ((gridStart.daysUntil(first) + first.daysInMonth) / 7).ceil();
    final items = ref.watch(openItemsProvider).value ?? const <Item>[];
    final byDay = <LocalDate, List<Item>>{};
    for (final item in items) {
      if (item.status == ItemStatus.active && item.doDate != null) {
        (byDay[item.doDate!] ??= []).add(item);
      }
    }
    final selected = _selected;

    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              tooltip: context.l10n.monthPrevious,
              onPressed: _offset > 0 ? () => setState(() => _offset--) : null,
            ),
            Expanded(
              child: Text(
                DateFormat.yMMMM().format(dateTimeOf(first)),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              tooltip: context.l10n.monthNextLabel,
              onPressed: () => setState(() => _offset++),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              for (final weekday in weekdaysFrom(weekStart))
                Expanded(
                  child: ExcludeSemantics(
                    child: Text(
                      weekdayShort(weekday),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        for (var w = 0; w < weeks; w++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                for (var d = 0; d < 7; d++)
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final day = gridStart.addDays(w * 7 + d);
                        final inMonth = day.month == first.month;
                        final count = byDay[day]?.length ?? 0;
                        return Semantics(
                          button: true,
                          selected: day == selected,
                          label: context.l10n.monthDayCount(
                            dateLabel(day, today),
                            count,
                          ),
                          child: ExcludeSemantics(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => setState(() => _selected = day),
                              child: Container(
                                height: 56,
                                margin: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: day == selected
                                      ? scheme.primaryContainer
                                      : null,
                                  borderRadius: BorderRadius.circular(12),
                                  border: day == today
                                      ? Border.all(color: glade.dawn, width: 2)
                                      : null,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${day.day}',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: inMonth
                                                ? scheme.onSurface
                                                : scheme.outline,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        for (var i = 0; i < min(count, 3); i++)
                                          Container(
                                            width: 5,
                                            height: 5,
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 1,
                                            ),
                                            decoration: BoxDecoration(
                                              color: scheme.primary,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        if (count > 3)
                                          Text(
                                            '+',
                                            style: theme.textTheme.labelSmall,
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        if (selected != null)
          DaySection(
            day: selected,
            today: today,
            emptyText: context.l10n.weekFree,
            children: [
              for (final item in byDay[selected] ?? const <Item>[])
                ItemTile(item: item, showDate: false),
            ],
          ),
      ],
    );
  }
}
