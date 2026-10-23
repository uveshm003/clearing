import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/glade.dart';
import '../../core/providers.dart';
import '../../core/router.dart';
import '../../domain/batch_block.dart';
import '../../domain/item.dart';
import '../../domain/today_rules.dart';
import '../../l10n/l10n.dart';
import '../format.dart';
import '../widgets/block_tile.dart';
import '../widgets/clearing_art.dart';
import '../widgets/empty_state.dart';
import '../widgets/glade_header.dart';
import '../widgets/item_tile.dart';
import '../widgets/mist_list.dart';
import '../widgets/pebble.dart';
import '../widgets/search_button.dart';
import '../widgets/section_header.dart';
import '../worksheet/print_worksheet.dart';

/// "Also today" collapses beyond this many items to keep Today small.
const _alsoTodayVisible = 5;

/// The menu value for printing, which isn't a route.
const _print = 'print';

/// From this many items on Today, offer the overwhelm reset (PRD §4.4).
const _offerResetFrom = 8;

/// Today (FR-04) in Glade: a serif date over a sky band that clears as the
/// day's items are done ("Open sky"), must-dos on their own pebble, and the
/// rest quiet below. Lists are built lazily and animate as items leave.
class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  bool _showAllAlso = false;
  bool _showCarried = false;

  @override
  Widget build(BuildContext context) {
    final view = ref.watch(todayViewProvider);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: switch (view) {
          AsyncData(:final value) => _body(context, value),
          AsyncError(:final error) => Center(child: Text('$error')),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }

  /// Search and the Today menu, in the header rather than an app bar.
  List<Widget> get _actions => [
    const SearchButton(),
    PopupMenuButton<String>(
      tooltip: context.l10n.commonMore,
      onSelected: (route) =>
          route == _print ? printWorksheet(context, ref) : context.push(route),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: Routes.review,
          child: Text(context.l10n.todayMenuWeeklyReview),
        ),
        PopupMenuItem(
          value: Routes.reset,
          child: Text(context.l10n.todayMenuOverwhelmReset),
        ),
        PopupMenuItem(
          value: _print,
          child: Text(context.l10n.todayMenuPrintWorksheet),
        ),
      ],
    ),
  ];

  Widget _body(BuildContext context, TodayView view) {
    final today = ref.watch(todayProvider).value;
    final cap = ref.watch(settingsProvider).value?.mustDoCap ?? 3;
    final doneToday = ref.watch(doneTodayProvider).value ?? 0;
    final glade = GladeTokens.of(context);
    final blocks = <BatchBlock>[
      for (final block in ref.watch(blocksProvider).value ?? const [])
        if (today != null && block.occursOn(today)) block,
    ];

    final left =
        view.mustDo.length + view.alsoToday.length + view.carriedOver.length;
    final date = today == null
        ? null
        : DateFormat('EEEE d MMMM').format(dateTimeOf(today));
    final header = GladeHeader(
      title: context.l10n.whenToday,
      subtitle: [
        ?date,
        if (left > 0) context.l10n.todayLeft(left),
        if (left == 0 && doneToday > 0) context.l10n.todayAllClear,
      ].join(' · '),
      sky: glade.sky(remaining: left, total: left + doneToday),
      actions: _actions,
    );

    if (view.isEmpty && blocks.isEmpty) {
      return Column(
        children: [
          header,
          if (view.thisWeekCount > 0) _ThisWeekRow(count: view.thisWeekCount),
          Expanded(
            child: EmptyState(
              icon: Icons.wb_sunny_outlined,
              scene: ClearingScene.clearing,
              title: context.l10n.todayEmptyTitle,
              message: context.l10n.todayEmptyMessage,
              action: TextButton(
                onPressed: () => context.push(Routes.intro),
                child: Text(context.l10n.todayHowClearingWorks),
              ),
            ),
          ),
        ],
      );
    }

    final also = view.alsoToday;
    final collapsed = !_showAllAlso && also.length > _alsoTodayVisible + 1;
    final visibleAlso = collapsed
        ? also.take(_alsoTodayVisible).toList()
        : also;

    Widget items(List<Item> list, {bool quiet = false}) => SliverMistList<Item>(
      items: list,
      keyOf: (item) => item.id,
      itemBuilder: (context, item, {leaving = false}) =>
          ItemTile(item: item, quiet: quiet, leaving: leaving),
    );

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: header),
        if (left >= _offerResetFrom)
          SliverToBoxAdapter(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: const Icon(Icons.self_improvement_outlined),
              title: Text(context.l10n.todayResetOfferTitle),
              subtitle: Text(context.l10n.todayResetOfferSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(Routes.reset),
            ),
          ),
        if (view.mustDo.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: SectionHeader(
              context.l10n.mustDo,
              trailing: context.l10n.todayMustDoCount(view.mustDo.length, cap),
            ),
          ),
          SliverPebble(highlight: true, sliver: items(view.mustDo)),
        ],
        if (blocks.isNotEmpty) ...[
          SliverToBoxAdapter(child: SectionHeader(context.l10n.todayBlocks)),
          SliverPebble(
            sliver: SliverList.list(
              children: [for (final block in blocks) BlockTile(block: block)],
            ),
          ),
        ],
        if (also.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: SectionHeader(
              view.mustDo.isEmpty
                  ? context.l10n.whenToday
                  : context.l10n.todayAlsoToday,
            ),
          ),
          SliverPebble(sliver: items(visibleAlso)),
          if (collapsed)
            SliverToBoxAdapter(
              child: Center(
                child: TextButton(
                  onPressed: () => setState(() => _showAllAlso = true),
                  child: Text(
                    context.l10n.todayShowMore(also.length - _alsoTodayVisible),
                  ),
                ),
              ),
            ),
        ],
        if (view.thisWeekCount > 0)
          SliverToBoxAdapter(child: _ThisWeekRow(count: view.thisWeekCount)),
        if (view.carriedOver.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: Text(
                context.l10n.todayCarriedOver(view.carriedOver.length),
              ),
              subtitle: Text(context.l10n.todayCarriedOverSubtitle),
              trailing: Icon(
                _showCarried ? Icons.expand_less : Icons.expand_more,
                semanticLabel: _showCarried
                    ? context.l10n.todayHide
                    : context.l10n.todayShow,
              ),
              onTap: () => setState(() => _showCarried = !_showCarried),
            ),
          ),
          if (_showCarried)
            SliverPebble(sliver: items(view.carriedOver, quiet: true)),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 96)),
      ],
    );
  }
}

class _ThisWeekRow extends StatelessWidget {
  const _ThisWeekRow({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: const Icon(Icons.view_week_outlined),
      title: Text(context.l10n.todayThisWeekCount(count)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(Routes.thisWeek),
    );
  }
}
