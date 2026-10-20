import 'package:flutter/material.dart';

import '../widgets/empty_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const EmptyState(
        icon: Icons.settings_outlined,
        title: 'Settings',
        message: 'Coming in a later milestone.',
      ),
    );
  }
}
