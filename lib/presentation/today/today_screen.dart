import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/providers.dart';
import '../../core/router.dart';
import '../../domain/today_rules.dart';
import '../format.dart';
import '../widgets/empty_state.dart';
import '../widgets/item_tile.dart';
import '../widgets/section_header.dart';

/// "Also today" collapses beyond this many items to keep Today small.
const _alsoTodayVisible = 5;

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
      ),
      body: switch (view) {
        AsyncData(:final value) => _body(context, value, cap),
        AsyncError(:final error) => Center(child: Text('$error')),
        _ => const SizedBox.shrink(),
      },
    );
  }

  Widget _body(BuildContext context, TodayView view, int cap) {
    if (view.isEmpty) {
      return Column(
        children: [
          if (view.thisWeekCount > 0) _ThisWeekRow(count: view.thisWeekCount),
          const Expanded(
            child: EmptyState(
              icon: Icons.wb_sunny_outlined,
              title: 'A clear day',
              message:
                  'Capture anything on your mind. You can decide what it '
                  'means later.',
            ),
          ),
        ],
      );
    }

    final also = view.alsoToday;
    final collapsed = !_showAllAlso && also.length > _alsoTodayVisible + 1;
    final visibleAlso = collapsed ? also.take(_alsoTodayVisible) : also;

    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
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
