import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../domain/enums.dart';
import '../capture/capture_sheet.dart';

final inboxCountProvider = StreamProvider<int>(
  (ref) => ref.watch(itemRepositoryProvider).watchCount(ItemStatus.inbox),
);

/// The four-tab scaffold (PRD §5).
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inboxCount = ref.watch(inboxCountProvider).value ?? 0;
    final showBadge = ref.watch(settingsProvider).value?.inboxBadge ?? true;

    return Scaffold(
      body: navigationShell,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Capture',
        onPressed: () => showCaptureSheet(context),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.wb_sunny_outlined),
            selectedIcon: Icon(Icons.wb_sunny),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: showBadge && inboxCount > 0,
              label: Text('$inboxCount'),
              child: const Icon(Icons.inbox_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: showBadge && inboxCount > 0,
              label: Text('$inboxCount'),
              child: const Icon(Icons.inbox),
            ),
            label: 'Inbox',
            tooltip: inboxCount > 0 ? 'Inbox, $inboxCount items' : 'Inbox',
          ),
          const NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: 'Upcoming',
          ),
          const NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Lists',
          ),
        ],
      ),
    );
  }
}
