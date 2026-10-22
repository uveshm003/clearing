import 'package:flutter/material.dart';

import '../widgets/section_header.dart';

/// "Reminders not arriving?" (PRD §7): what the system can do to reminders
/// and how to stop it. Plain text, since the app has no internet access.
class RemindersHelpScreen extends StatelessWidget {
  const RemindersHelpScreen({super.key});

  static const _steps = [
    (
      'Samsung',
      'Settings › Apps › Clearing › Battery › Unrestricted. Also check '
          'Settings › Battery › Background usage limits and remove Clearing '
          'from “Sleeping apps”.',
    ),
    (
      'Xiaomi, Redmi and POCO',
      'Settings › Apps › Manage apps › Clearing: turn on Autostart, and set '
          'Battery saver to “No restrictions”.',
    ),
    (
      'OnePlus, OPPO and realme',
      'Settings › Apps › Clearing › Battery: allow background activity and '
          'turn off “Optimise battery use”. On some versions, also allow '
          'Auto launch.',
    ),
    (
      'vivo and iQOO',
      'Settings › Battery › Background power consumption management: allow '
          'Clearing. Also turn on Autostart for Clearing in i Manager.',
    ),
    (
      'Huawei and Honor',
      'Settings › Battery › App launch › Clearing: switch to “Manage '
          'manually” and allow Auto-launch, Secondary launch and Run in '
          'background.',
    ),
    (
      'Pixel and other phones',
      'Settings › Apps › Clearing › App battery usage: Unrestricted.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders not arriving?')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Text(
              'Clearing schedules every reminder on your phone; nothing goes '
              'through a server. Some phones stop apps in the background to '
              'save battery, which can delay or drop reminders.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SectionHeader('First, check'),
          const ListTile(
            leading: Icon(Icons.notifications_outlined),
            title: Text('Notifications are allowed'),
            subtitle: Text('Settings › Apps › Clearing › Notifications'),
          ),
          const ListTile(
            leading: Icon(Icons.schedule),
            title: Text('Exact timing is on'),
            subtitle: Text(
              'Without it, Android may deliver reminders a few minutes late. '
              'See Exact timing in Clearing’s settings.',
            ),
          ),
          const ListTile(
            leading: Icon(Icons.do_not_disturb_on_outlined),
            title: Text('Do Not Disturb is off'),
            subtitle: Text('It silences or hides reminders while it’s on.'),
          ),
          const SectionHeader('Then, for your phone'),
          for (final (brand, steps) in _steps)
            ListTile(title: Text(brand), subtitle: Text(steps)),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Text(
              'Menu names vary between versions. dontkillmyapp.com has '
              'up-to-date steps for many more phones.',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
