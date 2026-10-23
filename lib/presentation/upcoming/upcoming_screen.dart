import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/item.dart';
import '../../domain/local_date.dart';
import '../../domain/upcoming_rules.dart';
import '../../l10n/l10n.dart';
import '../widgets/block_tile.dart';
import '../widgets/clearing_art.dart';
import '../widgets/day_rail.dart';
import '../widgets/empty_state.dart';
import '../widgets/glade_header.dart';
import '../widgets/pebble.dart';
import '../widgets/search_button.dart';
import 'week_view.dart';
import '../widgets/item_tile.dart';
import '../widgets/section_header.dart';

final _upcomingProvider = Provider<AsyncValue<UpcomingView>>((ref) {
  final today = ref.watch(todayProvider).value;
  return ref
      .watch(upcomingItemsProvider)
      .whenData(
        (items) => today == null
            ? (days: const [], waiting: const [])
            : buildUpcoming(items, today),
      );
});

/// The agenda of the next 30 days, or the week timeline (FR-15).
class UpcomingScreen extends ConsumerStatefulWidget {
  const UpcomingScreen({super.key});

  @override
  ConsumerState<UpcomingScreen> createState() => _UpcomingScreenState();
}

class _UpcomingScreenState extends ConsumerState<UpcomingScreen> {
  var _week = false;

  @override
  Widget build(BuildContext context) {
    final view = ref.watch(_upcomingProvider).value;
    final today = ref.watch(todayProvider).value;
    final allBlocks = ref.watch(blocksProvider).value ?? const [];
    // Days with items or batch blocks, in order.
    final days = <LocalDate, List<Item>>{
      for (final (day, items)
          in view?.days ?? const <(LocalDate, List<Item>)>[])
        day: items,
    };
    if (today != null) {
      for (final block in allBlocks) {
        for (final day in block.datesBetween(
          today.addDays(1),
          today.addDays(upcomingDays),
        )) {
          days.putIfAbsent(day, () => const []);
        }
      }
    }
    final sortedDays = days.keys.toList()..sort();
    final rows = <Widget Function()>[
      for (final day in sortedDays)
        () => DaySection(
          day: day,
          today: today!,
          children: [
            for (final block in allBlocks)
              if (block.occursOn(day)) BlockTile(block: block),
            for (final item in days[day]!)
              ItemTile(item: item, showDate: false),
          ],
        ),
      if (view != null && view.waiting.isNotEmpty) ...[
        () => SectionHeader(context.l10n.waitingOn),
        () => Pebble(
          children: [
            for (final item in view.waiting)
              ItemTile(item: item, showDate: false, key: ValueKey(item.id)),
          ],
        ),
      ],
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            GladeHeader(
              title: context.l10n.tabUpcoming,
              subtitle: _week
                  ? context.l10n.upcomingSubtitleWeek
                  : context.l10n.upcomingSubtitleAgenda,
              actions: [
                IconButton(
                  icon: Icon(
                    _week
                        ? Icons.view_agenda_outlined
                        : Icons.view_week_outlined,
                  ),
                  tooltip: _week
                      ? context.l10n.upcomingAgenda
                      : context.l10n.upcomingWeekView,
                  onPressed: () => setState(() => _week = !_week),
                ),
                const SearchButton(),
              ],
            ),
            Expanded(
              child: _week
                  ? const WeekView()
                  : view == null || today == null
                  ? const SizedBox.shrink()
                  : rows.isEmpty
                  ? EmptyState(
                      icon: Icons.event_note_outlined,
                      scene: ClearingScene.path,
                      title: context.l10n.upcomingEmptyTitle,
                      message: context.l10n.upcomingEmptyMessage,
                    )
                  // Built lazily: only the days on screen exist.
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 96),
                      itemCount: rows.length,
                      itemBuilder: (context, i) => rows[i](),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
