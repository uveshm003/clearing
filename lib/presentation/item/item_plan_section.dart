import 'package:flutter/material.dart';

import '../../domain/enums.dart';
import '../../domain/item.dart';
import '../../domain/local_date.dart';
import '../../domain/repeat_series.dart';
import '../../l10n/l10n.dart';
import '../format.dart';
import '../widgets/pebble.dart';
import '../widgets/reminder_editor.dart';
import 'series_calendar_screen.dart';

/// An item's plan (FR-07): when, who it's waiting on, its repeat, deadline
/// and reminders. The item screen owns the editing; this lays it out.
class ItemPlanSection extends StatelessWidget {
  const ItemPlanSection({
    super.key,
    required this.item,
    required this.series,
    required this.today,
    required this.whenText,
    required this.done,
    required this.onWhen,
    required this.onWaiting,
    required this.onFollowUp,
    required this.onRepeat,
    required this.onDeadline,
    required this.onClearDeadline,
  });

  final Item item;
  final RepeatSeries? series;
  final LocalDate today;
  final String whenText;
  final bool done;
  final VoidCallback onWhen;
  final VoidCallback onWaiting;
  final VoidCallback onFollowUp;
  final VoidCallback? onRepeat;
  final VoidCallback onDeadline;
  final VoidCallback onClearDeadline;

  @override
  Widget build(BuildContext context) {
    final series = this.series;
    return Pebble(
      children: [
        ListTile(
          leading: const Icon(Icons.event_outlined),
          title: Text(context.l10n.itemWhen),
          subtitle: Text(whenText),
          onTap: onWhen,
        ),
        if (item.status == ItemStatus.waiting) ...[
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(context.l10n.waitingOn),
            subtitle: Text(item.waitingOn ?? context.l10n.itemSomeone),
            onTap: onWaiting,
          ),
          ListTile(
            leading: const Icon(Icons.event_repeat_outlined),
            title: Text(context.l10n.itemFollowUp),
            subtitle: Text(
              item.followUpDate == null
                  ? context.l10n.itemNoDate
                  : dateLabel(item.followUpDate!, today),
            ),
            onTap: onFollowUp,
          ),
        ],
        if (item.status == ItemStatus.active || series != null)
          ListTile(
            leading: const Icon(Icons.repeat),
            title: Text(context.l10n.repeatTitle),
            subtitle: Text(switch (series) {
              null => context.l10n.itemDoesntRepeat,
              RepeatSeries(paused: true) => context.l10n.itemRepeatPaused(
                describeRepeat(series, today),
              ),
              _ => describeRepeat(series, today),
            }),
            onTap: done ? null : onRepeat,
            trailing: series == null
                ? null
                : IconButton(
                    icon: const Icon(Icons.calendar_month_outlined),
                    tooltip: context.l10n.itemSeeAllDates,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            SeriesCalendarScreen(seriesId: series.id),
                      ),
                    ),
                  ),
          ),
        ListTile(
          leading: const Icon(Icons.flag_outlined),
          title: Text(context.l10n.itemDeadline),
          subtitle: Text(
            item.deadline == null
                ? context.l10n.itemDeadlineNone
                : dateLabel(item.deadline!, today),
          ),
          trailing: item.deadline == null
              ? null
              : IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: context.l10n.itemRemoveDeadline,
                  onPressed: onClearDeadline,
                ),
          onTap: onDeadline,
        ),
        if (!done) ReminderSection(item: item),
      ],
    );
  }
}
