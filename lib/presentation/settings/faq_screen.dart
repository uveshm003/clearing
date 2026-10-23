import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router.dart';
import '../widgets/pebble.dart';
import '../widgets/section_header.dart';

/// Questions and answers, inside the app since it has no website to visit.
/// The first group covers what could cost people their data or trust.
class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const _data = <(String, String)>[
    (
      'Where are my things kept?',
      'Only on this phone. Clearing has no account, no server and no internet '
          'access, so nothing you write leaves the phone unless you export it.',
    ),
    (
      'How do I move to a new phone?',
      'Use Settings › Backup › Share a backup, and send the file somewhere you '
          'can reach from the new phone (email it to yourself, or save it to '
          'Drive). On the new phone, install Clearing and choose Restore from '
          'a backup. Android’s phone-to-phone transfer also moves Clearing’s '
          'data when you set up a new phone.',
    ),
    (
      'What happens if I uninstall Clearing?',
      'Everything in it is deleted with the app. Export a backup first if '
          'you might want it back. Clearing reminds you to export once a '
          'month, and you can change how often in Backup.',
    ),
    (
      'Can I use Clearing on two devices?',
      'Not in sync: each phone keeps its own copy. You can move things '
          'across with a backup: Restore › Merge adds what’s missing and keeps '
          'the newer copy of anything on both.',
    ),
  ];

  static const _habits = <(String, String)>[
    (
      'I did something by mistake. Can I undo it?',
      'Right after completing, deleting or moving an item, tap Undo on the '
          'note at the bottom of the screen. Deleted items stay in Lists › '
          'Trash for 30 days. Done items are in Lists › Done; untick one to '
          'bring it back.',
    ),
    (
      'What does “carried over” mean?',
      'Something planned for an earlier day that isn’t done yet. It stays on '
          'Today, quietly, until you do it or move it. Nothing turns red and '
          'nothing is counted against you.',
    ),
    (
      'What happens when I miss a repeating item?',
      'You choose per item. “Carry it over” keeps the missed one on Today '
          'until done, and the next one waits. “Skip it quietly” lets it go '
          'and starts fresh. Either way, missed days never pile up.',
    ),
    (
      'Why is Today limited to a few must-dos?',
      'A short list gets done; a long one turns into guilt. Everything else '
          'stays visible below. You can change the limit (1 to 5) in Settings.',
    ),
    (
      'Why are there no streaks or scores?',
      'They make a missed day feel like failure. Clearing counts what you '
          'cleared and planned, and nothing else.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    Widget entry((String, String) qa) => ExpansionTile(
      title: Text(qa.$1),
      shape: const Border(),
      collapsedShape: const Border(),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      expandedAlignment: Alignment.centerLeft,
      children: [Text(qa.$2)],
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Questions and answers')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: pebbleSections([
          const SectionHeader('Your data'),
          for (final qa in _data) entry(qa),
          const SectionHeader('Using Clearing'),
          for (final qa in _habits) entry(qa),
          const SectionHeader('Reminders'),
          ListTile(
            title: const Text('Reminders not arriving?'),
            subtitle: const Text('Battery settings to check on your phone'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.remindersHelp),
          ),
        ]),
      ),
    );
  }
}
