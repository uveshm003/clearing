import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/router.dart';
import '../../domain/item.dart';
import '../../domain/starter_suggestion.dart';
import '../item_commands.dart';
import '../widgets/search_button.dart';
import '../widgets/clearing_art.dart';
import '../widgets/empty_state.dart';
import '../widgets/glade_header.dart';
import '../widgets/mist_list.dart';
import '../widgets/pebble.dart';
import '../widgets/item_tile.dart';
import '../widgets/when_sheet.dart';

/// The inbox gets a gentle time estimate once it's long enough to feel heavy.
const _estimateThreshold = 10;

/// The Inbox (FR-02) in Glade: each thought on one pebble, swipe shortcuts
/// coloured from the theme, and a calm nudge to review when it grows long.
class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(inboxItemsProvider);
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: switch (items) {
          AsyncData(value: final items) when items.isEmpty => const Column(
            children: [
              GladeHeader(title: 'Inbox', actions: [SearchButton()]),
              Expanded(child: _EmptyInbox()),
            ],
          ),
          AsyncData(value: final items) => SlidableAutoCloseBehavior(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: GladeHeader(
                    title: 'Inbox',
                    actions: const [SearchButton()],
                    subtitle:
                        '${items.length} to decide · tap one, or swipe for '
                        'shortcuts',
                  ),
                ),
                if (items.length >= _estimateThreshold)
                  SliverToBoxAdapter(
                    child: Pebble(
                      highlight: true,
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      children: [
                        ListTile(
                          leading: const Icon(Icons.self_improvement_outlined),
                          title: Text(
                            'Inbox: ${items.length} — a review takes about '
                            '15 minutes',
                          ),
                          subtitle: const Text('Every item gets a place'),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: FilledButton.tonal(
                              onPressed: () => context.push(Routes.review),
                              child: const Text('Start review'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                SliverPebble(
                  sliver: SliverMistList<Item>(
                    items: items,
                    keyOf: (item) => item.id,
                    itemBuilder: (context, item, {leaving = false}) => leaving
                        ? ItemTile(item: item, leaving: true)
                        : _InboxRow(item: item),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: 96 + theme.visualDensity.vertical),
                ),
              ],
            ),
          ),
          AsyncError(:final error) => Center(child: Text('$error')),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}

/// An inbox item with the swipe shortcuts from PRD §4.2: Today and This week
/// to the right; Pick date, Someday and Delete to the left. The same actions
/// are exposed to TalkBack as custom semantics actions.
class _InboxRow extends ConsumerWidget {
  const _InboxRow({required this.item});

  final Item item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final today = ref.watch(todayProvider).value;

    Future<void> chooseDate() async {
      if (today == null) return;
      final choice = await pickDate(context, today: today);
      if (choice != null) await ref.plan(item, choice);
    }

    final actions = <String, VoidCallback>{
      'Today': () => ref.plan(item, const WhenToday()),
      'This week': () => ref.plan(item, const WhenThisWeek()),
      'Pick date': chooseDate,
      'Someday': () => ref.someday(context, item),
      'Delete': () => ref.trash(context, item),
    };

    SlidableAction action(
      String label,
      IconData icon,
      Color background,
      Color foreground,
    ) => SlidableAction(
      onPressed: (_) => actions[label]!(),
      icon: icon,
      label: label,
      backgroundColor: background,
      foregroundColor: foreground,
    );

    return Semantics(
      customSemanticsActions: {
        for (final MapEntry(:key, :value) in actions.entries)
          CustomSemanticsAction(label: key): value,
      },
      child: Slidable(
        key: ValueKey(item.id),
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            action(
              'Today',
              Icons.wb_sunny_outlined,
              scheme.primary,
              scheme.onPrimary,
            ),
            action(
              'This week',
              Icons.view_week_outlined,
              scheme.primaryContainer,
              scheme.onPrimaryContainer,
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            action(
              'Pick date',
              Icons.event_outlined,
              scheme.primaryContainer,
              scheme.onPrimaryContainer,
            ),
            action(
              'Someday',
              Icons.lightbulb_outline,
              scheme.surfaceContainerHigh,
              scheme.onSurface,
            ),
            action(
              'Delete',
              Icons.delete_outline,
              scheme.surfaceContainerHighest,
              scheme.onSurface,
            ),
          ],
        ),
        child: ItemTile(
          item: item,
          onTap: () => context.push(Routes.clarify(item.id)),
        ),
      ),
    );
  }
}

class _EmptyInbox extends ConsumerWidget {
  const _EmptyInbox();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(settingsProvider).value?.starterSuggestions;
    final suggestions = enabled == true
        ? (ref.watch(suggestionsProvider).value ?? const <StarterSuggestion>[])
              .where((s) => s.enabled)
              .toList()
        : const <StarterSuggestion>[];
    final lists = ref.watch(listsProvider).value ?? const [];

    return EmptyState(
      icon: Icons.inbox_outlined,
      scene: ClearingScene.nest,
      title: 'Inbox is empty',
      message:
          'Thoughts you capture land here until you decide what they mean.',
      action: suggestions.isEmpty
          ? null
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (final s in suggestions)
                  ActionChip(
                    label: Text(s.title),
                    onPressed: () => ref
                        .read(itemActionsProvider)
                        .capture(
                          s.title,
                          listId: lists
                              .where((l) => l.kind == s.listKind)
                              .firstOrNull
                              ?.id,
                        ),
                  ),
              ],
            ),
    );
  }
}
