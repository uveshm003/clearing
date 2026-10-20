import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/empty_state.dart';

class ListsScreen extends StatelessWidget {
  const ListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lists'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: const EmptyState(
        icon: Icons.list_alt_outlined,
        title: 'Lists',
        message: 'Life Admin, Errands and your own lists will live here.',
      ),
    );
  }
}
