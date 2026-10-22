import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/providers.dart';
import '../../core/router.dart';
import '../../domain/today_rules.dart';
import '../format.dart';
import '../widgets/search_button.dart';
import '../widgets/block_tile.dart';
import '../worksheet/print_worksheet.dart';
import '../widgets/empty_state.dart';
import '../widgets/item_tile.dart';
import '../widgets/section_header.dart';

/// "Also today" collapses beyond this many items to keep Today small.
const _alsoTodayVisible = 5;

/// The menu value for printing, which isn't a route.
const _print = 'print';

/// From this many items on Today, offer the overwhelm reset (PRD §4.4).
const _offerResetFrom = 8;

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  bool _showAllAlso = false;

  @override
  Widget build(BuildContext context) {
    final view = ref.watch(todayViewProvider);
    final today = ref.watch(todayProvider).value;
    final cap = ref.watch(settingsProvider).value?.mustDoCap ?? 3;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Today'),
            if (today != null)
              Text(
                DateFormat('EEEE d MMMM').format(dateTimeOf(today)),
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        actions: [
          const SearchButton(),
          PopupMenuButton<String>(
            tooltip: 'More',
            onSelected: (route) => route == _print
                ? printWorksheet(context, ref)
                : context.push(route),
            itemBuilder: (context) => const [
              PopupMenuItem(value: Routes.review, child: Text('Weekly review')),
              PopupMenuItem(
                value: Routes.reset,
                child: Text('Overwhelm reset'),
              ),
              PopupMenuItem(value: _print, child: Text('Print a worksheet')),
            ],
          ),
        ],
      ),
      body: switch (view) {
        AsyncData(:final value) => _body(context, value, cap),
        AsyncError(:final error) => Center(child: Text('$error')),
        _ => const SizedBox.shrink(),
      },
    );
  }

  Widget _body(BuildContext context, TodayView view, int cap) {
    final today = ref.watch(todayProvider).value;
    final blocks = [
      for (final block in ref.watch(blocksProvider).value ?? const [])
        if (today != null && block.occursOn(today)) block,
    ];
    if (view.isEmpty && blocks.isEmpty) {
      return Column(
        children: [
          if (view.thisWeekCount > 0) _ThisWeekRow(count: view.thisWeekCount),
          Expanded(
            child: EmptyState(
              icon: Icons.wb_sunny_outlined,
              title: 'A clear day',
              message:
                  'Capture anything on your mind. You can decide what it '
                  'means later.',
              action: TextButton(
                onPressed: () => context.push(Routes.intro),
                child: const Text('How Clearing works'),
              ),
            ),
          ),
        ],
      );
    }

    final also = view.alsoToday;
    final collapsed = !_showAllAlso && also.length > _alsoTodayVisible + 1;
    final visibleAlso = collapsed ? also.take(_alsoTodayVisible) : also;

    final total = view.mustDo.length + also.length + view.carriedOver.length;

    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        if (total >= _offerResetFrom)
          ListTile(
            leading: const Icon(Icons.self_improvement_outlined),
            title: const Text('Feeling like a lot?'),
            subtitle: const Text('A five-minute reset narrows it to one thing'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.reset),
          ),
        if (view.mustDo.isNotEmpty) ...[
          SectionHeader('Must-do', trailing: '${view.mustDo.length} of $cap'),
          for (final item in view.mustDo) ItemTile(item: item),
        ],
        if (also.isNotEmpty) ...[
          SectionHeader(view.mustDo.isEmpty ? 'Today' : 'Also today'),
          for (final item in visibleAlso) ItemTile(item: item),
          if (collapsed)
            TextButton(
              onPressed: () => setState(() => _showAllAlso = true),
              child: Text('Show ${also.length - _alsoTodayVisible} more'),
            ),
        ],
        if (blocks.isNotEmpty) ...[
          const SectionHeader('Blocks'),
          for (final block in blocks) BlockTile(block: block),
        ],
        if (view.thisWeekCount > 0) _ThisWeekRow(count: view.thisWeekCount),
        if (view.carriedOver.isNotEmpty)
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: Text('Carried over (${view.carriedOver.length})'),
              subtitle: const Text('Picking up where you left off'),
              children: [
                for (final item in view.carriedOver)
                  ItemTile(item: item, quiet: true),
              ],
            ),
          ),
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
      leading: const Icon(Icons.view_week_outlined),
      title: Text('This week ($count)'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(Routes.thisWeek),
    );
  }
}
