import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/router.dart';
import '../../domain/item.dart';
import '../../domain/starter_suggestion.dart';
import '../../l10n/l10n.dart';
import '../item_commands.dart';
import '../guidance/tip_card.dart';
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
          AsyncData(value: final items) when items.isEmpty => Column(
            children: [
              GladeHeader(
                title: context.l10n.tabInbox,
                actions: const [SearchButton()],
              ),
              const Expanded(child: _EmptyInbox()),
            ],
          ),
          AsyncData(value: final items) => SlidableAutoCloseBehavior(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: GladeHeader(
                    title: context.l10n.tabInbox,
                    actions: const [SearchButton()],
                    subtitle: context.l10n.inboxToDecide(items.length),
                  ),
                ),
                SliverToBoxAdapter(
                  child: TipCard(
                    id: Tips.inboxSwipe,
                    text: context.l10n.tipInboxSwipe,
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
                            context.l10n.inboxReviewEstimate(items.length),
                          ),
                          subtitle: Text(context.l10n.inboxReviewSubtitle),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: FilledButton.tonal(
                              onPressed: () => context.push(Routes.review),
                              child: Text(context.l10n.inboxStartReview),
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

/// The inbox swipe shortcuts, so their labels can be translated.
enum _Swipe { today, thisWeek, pickDate, someday, delete }

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

    final l10n = context.l10n;
    final labels = <_Swipe, String>{
      _Swipe.today: l10n.whenToday,
      _Swipe.thisWeek: l10n.whenThisWeek,
      _Swipe.pickDate: l10n.inboxSwipePickDate,
      _Swipe.someday: l10n.someday,
      _Swipe.delete: l10n.commonDelete,
    };
    final actions = <_Swipe, VoidCallback>{
      _Swipe.today: () => ref.plan(item, const WhenToday()),
      _Swipe.thisWeek: () => ref.plan(item, const WhenThisWeek()),
      _Swipe.pickDate: chooseDate,
      _Swipe.someday: () => ref.someday(context, item),
      _Swipe.delete: () => ref.trash(context, item),
    };

    SlidableAction action(
      _Swipe swipe,
      IconData icon,
      Color background,
      Color foreground,
    ) => SlidableAction(
      onPressed: (_) => actions[swipe]!(),
      icon: icon,
      label: labels[swipe],
      backgroundColor: background,
      foregroundColor: foreground,
    );

    return Semantics(
      customSemanticsActions: {
        for (final MapEntry(:key, :value) in actions.entries)
          CustomSemanticsAction(label: labels[key]!): value,
      },
      child: Slidable(
        key: ValueKey(item.id),
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            action(
              _Swipe.today,
              Icons.wb_sunny_outlined,
              scheme.primary,
              scheme.onPrimary,
            ),
            action(
              _Swipe.thisWeek,
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
              _Swipe.pickDate,
              Icons.event_outlined,
              scheme.primaryContainer,
              scheme.onPrimaryContainer,
            ),
            action(
              _Swipe.someday,
              Icons.lightbulb_outline,
              scheme.surfaceContainerHigh,
              scheme.onSurface,
            ),
            action(
              _Swipe.delete,
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
      title: context.l10n.inboxEmptyTitle,
      message: context.l10n.inboxEmptyMessage,
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
