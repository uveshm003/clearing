import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/glade.dart';
import '../../core/providers.dart';
import '../../core/router.dart';
import '../../data/device.dart';
import '../../domain/batch_block.dart';
import '../../domain/enums.dart';
import '../../domain/item.dart';
import '../../domain/item_context.dart';
import '../../domain/local_date.dart';
import '../../domain/today_rules.dart';
import '../../l10n/l10n.dart';
import '../format.dart';
import '../grove/invitation_card.dart';
import '../guidance/field_notes_hooks.dart';
import '../guidance/tip_card.dart';
import '../widgets/block_tile.dart';
import '../widgets/clearing_art.dart';
import '../widgets/empty_state.dart';
import '../widgets/glade_header.dart';
import '../widgets/item_tile.dart';
import '../widgets/mist_list.dart';
import '../widgets/pebble.dart';
import '../widgets/pull_to_capture.dart';
import '../widgets/search_button.dart';
import '../widgets/section_header.dart';
import '../worksheet/print_worksheet.dart';
import 'all_clear.dart';
import 'have_time_sheet.dart';
import 'plan_day_sheet.dart';

/// "Also today" collapses beyond this many items to keep Today small.
const _alsoTodayVisible = 5;

/// Menu values that aren't routes.
const _print = 'print';
const _haveTime = 'time';

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

  /// The day was just cleared, while watching.
  bool _celebrate = false;

  /// "What fits now": at most this long, and in this context.
  int? _fitMinutes;
  String? _fitContext;

  @override
  void initState() {
    super.initState();
    ref.listenManual<AsyncValue<TodayView>>(todayViewProvider, (prev, next) {
      final before = prev?.value;
      final now = next.value;
      if (before == null || now == null) return;
      final wasLeft = _left(before);
      if (wasLeft > 0 && _left(now) == 0) _allClear();
    });
  }

  static int _left(TodayView view) =>
      view.mustDo.length + view.alsoToday.length + view.carriedOver.length;

  /// The last thing on Today was ticked: a moment, a record, a field note.
  Future<void> _allClear() async {
    setState(() => _celebrate = true);
    HapticFeedback.mediumImpact();
    final settings = ref.read(settingsProvider).value;
    if (settings?.sounds ?? false) {
      await ref.read(deviceGatewayProvider).chime(Chime.clear);
    }
    await ref.read(dayRecordActionsProvider).markAllClear();
    noteFieldNote(ref, FieldNote.openSky);
  }

  @override
  Widget build(BuildContext context) {
    final view = ref.watch(todayViewProvider);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: switch (view) {
          AsyncData(:final value) => PullToCapture(
            child: _body(context, value),
          ),
          AsyncError(:final error) => Center(child: Text('$error')),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }

  /// Search and the Today menu, in the header rather than an app bar.
  List<Widget> _actions(bool grove) => [
    const SearchButton(),
    PopupMenuButton<String>(
      tooltip: context.l10n.commonMore,
      onSelected: (route) => switch (route) {
        _print => printWorksheet(context, ref),
        _haveTime => showHaveTimeSheet(context),
        _ => context.push(route),
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: Routes.review,
          child: Text(context.l10n.todayMenuWeeklyReview),
        ),
        PopupMenuItem(
          value: Routes.reset,
          child: Text(context.l10n.todayMenuOverwhelmReset),
        ),
        if (grove)
          PopupMenuItem(
            value: Routes.grove,
            child: Text(context.l10n.todayMenuGrove),
          ),
        PopupMenuItem(
          value: _haveTime,
          child: Text(context.l10n.todayMenuHaveTime),
        ),
        PopupMenuItem(
          value: Routes.reorderToday,
          child: Text(context.l10n.todayMenuReorder),
        ),
        PopupMenuItem(
          value: Routes.recent,
          child: Text(context.l10n.todayMenuRecent),
        ),
        PopupMenuItem(
          value: _print,
          child: Text(context.l10n.todayMenuPrintWorksheet),
        ),
      ],
    ),
  ];

  String _greeting(DateTime now) => switch (now.hour) {
    < 12 => context.l10n.todayGoodMorning,
    < 17 => context.l10n.todayGoodAfternoon,
    _ => context.l10n.todayGoodEvening,
  };

  /// Whether [item] fits "what fits now".
  bool _fits(Item item, Map<String, Set<String>> contexts) {
    if (_fitMinutes case final max?) {
      if (item.effort == null || item.effort! > max) return false;
    }
    if (_fitContext case final wanted?) {
      if (!(contexts[item.id]?.contains(wanted) ?? false)) return false;
    }
    return true;
  }

  Widget _body(BuildContext context, TodayView view) {
    final today = ref.watch(todayProvider).value;
    final settings = ref.watch(settingsProvider).value;
    final cap = settings?.mustDoCap ?? 3;
    final doneToday = ref.watch(doneTodayProvider).value ?? 0;
    final now = ref.watch(clockProvider)();
    final glade = GladeTokens.of(context);
    final blocks = <BatchBlock>[
      for (final block in ref.watch(blocksProvider).value ?? const [])
        if (today != null && block.occursOn(today)) block,
    ];
    final itemContexts = ref.watch(itemContextsProvider).value ?? const {};
    final contexts = ref.watch(contextsProvider).value ?? const [];
    final tomorrow = today == null
        ? 0
        : (ref.watch(upcomingItemsProvider).value ?? const <Item>[])
              .where(
                (i) =>
                    i.status == ItemStatus.active &&
                    i.doDate == today.addDays(1),
              )
              .length;

    final left = _left(view);
    final date = today == null
        ? null
        : DateFormat('EEEE d MMMM').format(dateTimeOf(today));
    final header = GladeHeader(
      title: context.l10n.whenToday,
      subtitle: [
        if (left > 0 || doneToday == 0) _greeting(now),
        ?date,
        if (left > 0) context.l10n.todayLeft(left),
        if (left == 0 && doneToday > 0) context.l10n.todayAllClear,
      ].join(' · '),
      sky: glade.sky(remaining: left, total: left + doneToday),
      actions: _actions(settings?.groveEnabled ?? false),
    );

    final tomorrowRow = tomorrow == 0
        ? null
        : ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            leading: const Icon(Icons.wb_twilight),
            title: Text(context.l10n.todayTomorrowPeek(tomorrow)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go(Routes.upcoming),
          );

    final planPrompt =
        settings != null &&
            today != null &&
            settings.planMyDay &&
            now.hour >= 5 &&
            view.mustDo.isEmpty &&
            view.alsoToday.isEmpty &&
            view.thisWeekCount > 0 &&
            settings.lastPlanPromptOn != today
        ? _PlanDayRow(today: today)
        : null;

    if (view.isEmpty && blocks.isEmpty) {
      return ListView(
        children: [
          header,
          const InvitationCard(),
          ?planPrompt,
          if (view.thisWeekCount > 0) _ThisWeekRow(count: view.thisWeekCount),
          if (doneToday > 0)
            AllClear(closed: doneToday, celebrate: _celebrate)
          else
            SizedBox(
              height: 420,
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
          ?tomorrowRow,
          const SizedBox(height: 96),
        ],
      );
    }

    // "What fits now" shows once anything on Today has a length or context.
    final everything = [...view.mustDo, ...view.alsoToday, ...view.carriedOver];
    final usedContexts = {
      for (final item in everything) ...?itemContexts[item.id],
    };
    final canFilter =
        everything.any((i) => i.effort != null) || usedContexts.isNotEmpty;
    final filtering = _fitMinutes != null || _fitContext != null;
    List<Item> fit(List<Item> items) =>
        filtering ? items.where((i) => _fits(i, itemContexts)).toList() : items;
    final mustDo = fit(view.mustDo);
    final also = fit(view.alsoToday);
    final carried = fit(view.carriedOver);

    // The first timed item still to come gets the "now" line.
    final nowMinutes = now.hour * 60 + now.minute;
    final nextTimed = [...mustDo, ...also]
        .where(
          (i) =>
              i.doTime != null && i.doDate == today && i.doTime! >= nowMinutes,
        )
        .fold<Item?>(
          null,
          (best, i) => best == null || i.doTime! < best.doTime! ? i : best,
        );
    final anyPastTimed = [...mustDo, ...also].any(
      (i) => i.doTime != null && i.doDate == today && i.doTime! < nowMinutes,
    );
    final nowLineId = anyPastTimed ? nextTimed?.id : null;

    final collapsed = !_showAllAlso && also.length > _alsoTodayVisible + 1;
    final visibleAlso = collapsed
        ? also.take(_alsoTodayVisible).toList()
        : also;

    Widget items(List<Item> list, {bool quiet = false}) => SliverMistList<Item>(
      items: list,
      keyOf: (item) => item.id,
      itemBuilder: (context, item, {leaving = false}) => ItemTile(
        item: item,
        quiet: quiet,
        leaving: leaving,
        swipe: true,
        nowLine: item.id == nowLineId,
      ),
    );

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: header),
        SliverToBoxAdapter(
          child: TipCard(id: Tips.todayRing, text: context.l10n.tipTodayRing),
        ),
        const SliverToBoxAdapter(child: InvitationCard()),
        if (canFilter)
          SliverToBoxAdapter(
            child: _FitsNow(
              minutes: _fitMinutes,
              contextId: _fitContext,
              contexts: [
                for (final c in contexts)
                  if (usedContexts.contains(c.id)) c,
              ],
              onMinutes: (m) => setState(() => _fitMinutes = m),
              onContext: (c) => setState(() => _fitContext = c),
            ),
          ),
        if (filtering && mustDo.isEmpty && also.isEmpty && carried.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: Text(context.l10n.fitsNowNone),
            ),
          ),
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
        if (mustDo.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: SectionHeader(
              context.l10n.mustDo,
              trailing: context.l10n.todayMustDoCount(view.mustDo.length, cap),
            ),
          ),
          SliverPebble(highlight: true, sliver: items(mustDo)),
          if (settings?.seenTips.contains(Tips.todayRing) ?? false)
            SliverToBoxAdapter(
              child: TipCard(
                id: Tips.glossMustDo,
                text: context.l10n.glossMustDo,
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              ),
            ),
        ],
        if (blocks.isNotEmpty && !filtering) ...[
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
              mustDo.isEmpty
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
        if (carried.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: Text(context.l10n.todayCarriedOver(carried.length)),
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
          if (_showCarried) ...[
            SliverToBoxAdapter(
              child: TipCard(
                id: Tips.glossCarried,
                text: context.l10n.glossCarried,
              ),
            ),
            SliverPebble(sliver: items(carried, quiet: true)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: FilledButton.tonal(
                    onPressed: () => context.push(Routes.decide),
                    child: Text(context.l10n.todayDecideThese),
                  ),
                ),
              ),
            ),
          ],
        ],
        if (tomorrowRow != null) SliverToBoxAdapter(child: tomorrowRow),
        // One tip at a time, and below the day rather than above it.
        if (settings?.seenTips.contains(Tips.todayRing) ?? false)
          SliverToBoxAdapter(
            child: TipCard(
              id: Tips.selectMany,
              text: context.l10n.selectHint,
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            ),
          ),
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

/// "Plan your day?": a quiet row, once a day, when Today is empty but This
/// week isn't.
class _PlanDayRow extends ConsumerWidget {
  const _PlanDayRow({required this.today});

  final LocalDate today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.read(settingsRepositoryProvider);
    Future<void> seen({bool never = false}) async {
      final latest = await repository.get();
      await repository.save(
        latest.copyWith(
          lastPlanPromptOn: () => today,
          planMyDay: never ? false : null,
        ),
      );
    }

    return Pebble(
      highlight: true,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      children: [
        ListTile(
          leading: const Icon(Icons.wb_sunny_outlined),
          title: Text(context.l10n.planDayPrompt),
          subtitle: Text(context.l10n.planDayPromptHint),
          onTap: () async {
            final thisWeek = (ref.read(todayItemsProvider).value ?? const [])
                .where(isThisWeek)
                .toList();
            await seen();
            if (context.mounted) await showPlanDaySheet(context, thisWeek);
          },
          trailing: IconButton(
            icon: const Icon(Icons.close),
            tooltip: context.l10n.commonClose,
            onPressed: seen,
          ),
        ),
      ],
    );
  }
}

/// "What fits now": a length, or a context, at a time.
class _FitsNow extends StatelessWidget {
  const _FitsNow({
    required this.minutes,
    required this.contextId,
    required this.contexts,
    required this.onMinutes,
    required this.onContext,
  });

  final int? minutes;
  final String? contextId;
  final List<ItemContext> contexts;
  final ValueChanged<int?> onMinutes;
  final ValueChanged<String?> onContext;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: context.l10n.fitsNow,
      child: SizedBox(
        height: 56,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          children: [
            for (final m in const [5, 15])
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: FilterChip(
                  label: Text(effortLabel(m)),
                  selected: minutes == m,
                  onSelected: (on) => onMinutes(on ? m : null),
                ),
              ),
            for (final c in contexts)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: FilterChip(
                  label: Text(contextLabel(c)),
                  selected: contextId == c.id,
                  onSelected: (on) => onContext(on ? c.id : null),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
