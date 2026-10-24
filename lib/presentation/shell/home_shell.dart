import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/glade.dart';
import '../../core/providers.dart';
import '../../core/router.dart';
import '../../domain/enums.dart';
import '../../l10n/l10n.dart';
import '../capture/capture_sheet.dart';
import '../grove/field_note_text.dart';
import '../guidance/coach_marks.dart';
import '../grove/grove_widget_sync.dart';
import '../item/item_screen.dart';
import '../selection.dart';
import '../settings/whats_new.dart';
import 'two_pane.dart';

final inboxCountProvider = StreamProvider<int>(
  (ref) => ref.watch(itemRepositoryProvider).watchCount(ItemStatus.inbox),
);

/// The four-tab scaffold (PRD §5). On phones: tabs at the bottom. From 840
/// dp wide: a side rail, the list in a column no wider than 640 dp, and the
/// open item in a pane beside it.
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  /// Each tab's icon, its selected icon, and its label.
  static List<(IconData, IconData, String)> _tabs(AppLocalizations strings) => [
    (Icons.wb_sunny_outlined, Icons.wb_sunny, strings.tabToday),
    (Icons.inbox_outlined, Icons.inbox, strings.tabInbox),
    (Icons.event_note_outlined, Icons.event_note, strings.tabUpcoming),
    (Icons.list_alt_outlined, Icons.list_alt, strings.tabLists),
  ];

  static const _coachTargets = [
    CoachTarget.today,
    CoachTarget.inbox,
    CoachTarget.upcoming,
    CoachTarget.lists,
  ];

  void _go(WidgetRef ref, int index) {
    ref.read(selectionProvider.notifier).clear();
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  /// Keys for a keyboard on tablets and Chromebooks: N captures, / searches,
  /// 1–4 switch tabs. Only while no text field has focus.
  Widget _shortcuts(BuildContext context, WidgetRef ref, Widget child) {
    bool typing() {
      final focus = FocusManager.instance.primaryFocus?.context?.widget;
      return focus is EditableText;
    }

    void unlessTyping(VoidCallback action) {
      if (!typing()) action();
    }

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyN): () =>
            unlessTyping(() => showCaptureSheet(context)),
        const SingleActivator(LogicalKeyboardKey.slash): () =>
            unlessTyping(() => context.push(Routes.search)),
        for (final (i, key) in const [
          LogicalKeyboardKey.digit1,
          LogicalKeyboardKey.digit2,
          LogicalKeyboardKey.digit3,
          LogicalKeyboardKey.digit4,
        ].indexed)
          SingleActivator(key): () => unlessTyping(() => _go(ref, i)),
      },
      child: Focus(
        autofocus: true,
        child: Stack(children: [child, const CoachOverlay()]),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selecting = ref.watch(selectionProvider).isNotEmpty;
    final inboxCount = ref.watch(inboxCountProvider).value ?? 0;
    final showBadge = ref.watch(settingsProvider).value?.inboxBadge ?? true;
    final tabs = _tabs(context.l10n);

    Widget icon(int i, {required bool selected}) {
      final glyph = KeyedSubtree(
        // On whichever icon is showing, so a coach mark can find the tab.
        key: selected == (i == navigationShell.currentIndex)
            ? coachKeys[_coachTargets[i]]
            : null,
        child: Icon(selected ? tabs[i].$2 : tabs[i].$1),
      );
      if (i != 1) return glyph;
      return Badge(
        isLabelVisible: showBadge && inboxCount > 0,
        label: Text('$inboxCount'),
        child: glyph,
      );
    }

    String? tooltip(int i) => i == 1 && inboxCount > 0
        ? context.l10n.shellInboxTooltip(inboxCount)
        : null;

    final capture = FloatingActionButton(
      key: coachKeys[CoachTarget.capture],
      tooltip: context.l10n.shellCapture,
      onPressed: () => showCaptureSheet(context),
      child: const Icon(Icons.add),
    );
    final body = SelectionScope(
      child: WhatsNewWatcher(
        child: ShellScope(
          child: Column(
            children: [
              Expanded(child: GroveWidgetSync(child: navigationShell)),
              const FieldNoteToast(),
            ],
          ),
        ),
      ),
    );

    if (!isTwoPane(context)) {
      return _shortcuts(
        context,
        ref,
        Scaffold(
          body: body,
          floatingActionButton: selecting ? null : capture,
          bottomNavigationBar: selecting
              ? const SelectionBar()
              : NavigationBar(
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: (i) => _go(ref, i),
                  destinations: [
                    for (var i = 0; i < tabs.length; i++)
                      NavigationDestination(
                        icon: icon(i, selected: false),
                        selectedIcon: icon(i, selected: true),
                        label: tabs[i].$3,
                        tooltip: tooltip(i),
                      ),
                  ],
                ),
        ),
      );
    }

    final selected = ref.watch(selectedItemProvider);
    final scheme = Theme.of(context).colorScheme;
    return _shortcuts(
      context,
      ref,
      Scaffold(
        bottomNavigationBar: selecting ? const SelectionBar() : null,
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (i) => _go(ref, i),
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: GladeSpace.sm),
                child: capture,
              ),
              destinations: [
                for (var i = 0; i < tabs.length; i++)
                  NavigationRailDestination(
                    icon: Tooltip(
                      message: tooltip(i) ?? tabs[i].$3,
                      child: icon(i, selected: false),
                    ),
                    selectedIcon: icon(i, selected: true),
                    label: Text(tabs[i].$3),
                  ),
              ],
            ),
            Expanded(
              flex: 5,
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: GladeSpace.maxColumn,
                  ),
                  child: body,
                ),
              ),
            ),
            if (selected != null) ...[
              VerticalDivider(width: 1, color: scheme.outlineVariant),
              Expanded(
                flex: 4,
                child: ItemScreen(
                  key: ValueKey(selected),
                  itemId: selected,
                  onClose: () =>
                      ref.read(selectedItemProvider.notifier).close(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
