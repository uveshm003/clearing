import 'package:flutter/material.dart';

import '../widgets/empty_state.dart';

class UpcomingScreen extends StatelessWidget {
  const UpcomingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upcoming')),
      body: const EmptyState(
        icon: Icons.event_note_outlined,
        title: 'Nothing scheduled',
        message: 'Items with a date in the next 30 days show up here.',
      ),
    );
  }
}
