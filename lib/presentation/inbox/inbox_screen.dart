import 'package:flutter/material.dart';

import '../widgets/empty_state.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inbox')),
      body: const EmptyState(
        icon: Icons.inbox_outlined,
        title: 'Inbox is empty',
        message:
            'Thoughts you capture land here until you decide what they '
            'mean.',
      ),
    );
  }
}
