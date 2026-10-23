import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router.dart';
import '../../l10n/l10n.dart';
import '../widgets/pebble.dart';
import '../widgets/section_header.dart';

/// Questions and answers, inside the app since it has no website to visit.
/// The first group covers what could cost people their data or trust.
class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final data = <(String, String)>[
      (l10n.faqWhereKeptQ, l10n.faqWhereKeptA),
      (l10n.faqNewPhoneQ, l10n.faqNewPhoneA),
      (l10n.faqUninstallQ, l10n.faqUninstallA),
      (l10n.faqTwoDevicesQ, l10n.faqTwoDevicesA),
    ];
    final habits = <(String, String)>[
      (l10n.faqUndoQ, l10n.faqUndoA),
      (l10n.faqCarriedOverQ, l10n.faqCarriedOverA),
      (l10n.faqMissedRepeatQ, l10n.faqMissedRepeatA),
      (l10n.faqMustDoLimitQ, l10n.faqMustDoLimitA),
      (l10n.faqNoStreaksQ, l10n.faqNoStreaksA),
    ];

    Widget entry((String, String) qa) => ExpansionTile(
      title: Text(qa.$1),
      shape: const Border(),
      collapsedShape: const Border(),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      expandedAlignment: Alignment.centerLeft,
      children: [Text(qa.$2)],
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.faqTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: pebbleSections([
          SectionHeader(l10n.faqSectionData),
          for (final qa in data) entry(qa),
          SectionHeader(l10n.faqSectionUsing),
          for (final qa in habits) entry(qa),
          SectionHeader(l10n.faqSectionReminders),
          ListTile(
            title: Text(l10n.remindersHelpTitle),
            subtitle: Text(l10n.faqRemindersHelpSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.remindersHelp),
          ),
        ]),
      ),
    );
  }
}
