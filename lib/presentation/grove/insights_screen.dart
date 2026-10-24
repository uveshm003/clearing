import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/glade.dart';
import '../../core/providers.dart';
import '../../domain/enums.dart';
import '../../domain/grove.dart';
import '../../domain/insights.dart';
import '../../domain/item_event.dart';
import '../../l10n/l10n.dart';
import '../format.dart';
import '../widgets/pebble.dart';
import '../widgets/section_header.dart';

/// The last 90 days of events, for the Inbox wait.
final _recentEventsProvider = FutureProvider.autoDispose<List<ItemEvent>>((
  ref,
) {
  final now = ref.watch(clockProvider)();
  return ref
      .watch(eventRepositoryProvider)
      .since(now.subtract(const Duration(days: 90)));
});

/// "Your rhythm" (§5.9): when things get closed, how long they wait, which
/// lists move. Observations, never judgements; all worked out on the phone.
class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final now = ref.watch(clockProvider)();
    final inputs = ref.watch(groveInputsProvider);
    final lists = ref.watch(listsProvider).value ?? const [];
    final open = ref.watch(openItemsProvider).value ?? const [];
    final done = ref.watch(doneItemsProvider).value ?? const [];
    final events = ref.watch(_recentEventsProvider).value ?? const [];
    final since = now.subtract(const Duration(days: 90));
    final recent = [
      for (final thing in inputs?.closed ?? const <ClosedThing>[])
        if (thing.completedAt.isAfter(since)) thing,
    ];

    final hours = closesByHour(recent);
    final part = busiestPart(hours);
    final inboxWait = median(inboxWaits(events));
    final closeTime = median(recent.map((c) => c.waitedDays));
    String? listName(String? id) =>
        lists.where((l) => l.id == id).firstOrNull?.name;
    final byList = groupBy(
      done.where((i) => i.listId != null && i.completedAt != null),
      (i) => i.listId!,
    );
    final fastest = byList.entries
        .where((e) => e.value.length >= 3)
        .map(
          (e) => (
            id: e.key,
            days: median(
              e.value.map((i) => i.completedAt!.difference(i.createdAt).inDays),
            )!,
          ),
        )
        .sortedBy<num>((e) => e.days)
        .firstOrNull;
    final parked = groupBy(
      open.where((i) => i.status == ItemStatus.someday && i.listId != null),
      (i) => i.listId!,
    ).entries.sortedBy<num>((e) => -e.value.length).firstOrNull;

    final observations = [
      if (part != null)
        switch (part) {
          DayPart.morning => l10n.insightsMorning,
          DayPart.afternoon => l10n.insightsAfternoon,
          DayPart.evening => l10n.insightsEvening,
          DayPart.night => l10n.insightsNight,
        },
      if (inboxWait != null) l10n.insightsInboxWait(inboxWait),
      if (closeTime != null && recent.length >= 5)
        l10n.insightsCloseTime(closeTime),
      if (fastest != null && listName(fastest.id) != null)
        l10n.insightsFastestList(listName(fastest.id)!, fastest.days),
      if (parked != null &&
          parked.value.length >= 3 &&
          listName(parked.key) != null)
        l10n.insightsMostParked(listName(parked.key)!),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.insightsTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Text(
              l10n.insightsHint,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(l10n.insightsEmpty),
            )
          else ...[
            SectionHeader(l10n.insightsByHour),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: HourChart(hours: hours),
            ),
            for (final text in observations)
              ListTile(
                leading: const Icon(Icons.eco_outlined),
                title: Text(text),
              ),
            SectionHeader(l10n.insightsTable),
            Pebble(
              children: [
                for (final (hour, count) in hours.indexed)
                  if (count > 0)
                    ListTile(
                      dense: true,
                      title: Text(timeLabel(context, hour * 60)),
                      trailing: Text('$count'),
                    ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.ios_share),
            title: Text(l10n.insightsShareStats),
            subtitle: Text(l10n.insightsShareStatsHint),
            onTap: () async {
              final info = await PackageInfo.fromPlatform();
              final reviews = inputs?.reviews.length ?? 0;
              await SharePlus.instance.share(
                ShareParams(
                  text: const JsonEncoder.withIndent('  ').convert({
                    'app': info.version,
                    'open': {
                      for (final status in ItemStatus.values)
                        if (status != ItemStatus.done &&
                            status != ItemStatus.trashed)
                          status.name: open
                              .where((i) => i.status == status)
                              .length,
                    },
                    'closedLast90Days': recent.length,
                    'reviews': reviews,
                    'medianInboxWaitDays': inboxWait,
                    'closesByHour': hours,
                  }),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Closes by hour as thin moss bars on a recessive baseline. One series, so
/// no legend: the heading names it. A tooltip on each bar, and the same
/// numbers as a list below for anyone who'd rather read them.
class HourChart extends StatelessWidget {
  const HourChart({super.key, required this.hours});

  final List<int> hours;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tallest = max(1, hours.max);
    final peak = hours.indexOf(hours.max);
    return Semantics(
      label: context.l10n.insightsByHourSummary(timeLabel(context, peak * 60)),
      child: ExcludeSemantics(
        child: Column(
          children: [
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final (hour, count) in hours.indexed)
                    Expanded(
                      child: Tooltip(
                        message: context.l10n.insightsBarTooltip(
                          timeLabel(context, hour * 60),
                          count,
                        ),
                        child: Padding(
                          // A 2 px gap between bars.
                          padding: const EdgeInsets.symmetric(horizontal: 1),
                          child: Container(
                            height: count == 0 ? 0 : 6 + 110 * count / tallest,
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Divider(height: 1, color: scheme.outlineVariant),
            const SizedBox(height: GladeSpace.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final hour in const [0, 6, 12, 18, 23])
                  Text(
                    timeLabel(context, hour * 60),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
