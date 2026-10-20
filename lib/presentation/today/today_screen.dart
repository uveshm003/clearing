import 'package:flutter/material.dart';

import '../widgets/empty_state.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Today')),
      body: const EmptyState(
        icon: Icons.wb_sunny_outlined,
        title: 'A clear day',
        message:
            'Capture anything on your mind. You can decide what it '
            'means later.',
      ),
    );
  }
}
