import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../widgets/pebble.dart';
import '../widgets/section_header.dart';

/// "Reminders not arriving?" (PRD §7): what the system can do to reminders
/// and how to stop it. Plain text, since the app has no internet access.
class RemindersHelpScreen extends StatelessWidget {
  const RemindersHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final steps = [
      ('Samsung', l10n.remindersHelpSamsung),
      (l10n.remindersHelpBrandXiaomi, l10n.remindersHelpXiaomi),
      (l10n.remindersHelpBrandOnePlus, l10n.remindersHelpOnePlus),
      (l10n.remindersHelpBrandVivo, l10n.remindersHelpVivo),
      (l10n.remindersHelpBrandHuawei, l10n.remindersHelpHuawei),
      (l10n.remindersHelpBrandPixel, l10n.remindersHelpPixel),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.remindersHelpTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: pebbleSections([
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Text(
              l10n.remindersHelpIntro,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          SectionHeader(l10n.remindersHelpFirstCheck),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: Text(l10n.remindersHelpNotificationsTitle),
            subtitle: Text(l10n.remindersHelpNotificationsPath),
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: Text(l10n.remindersHelpExactTitle),
            subtitle: Text(l10n.remindersHelpExactBody),
          ),
          ListTile(
            leading: const Icon(Icons.do_not_disturb_on_outlined),
            title: Text(l10n.remindersHelpDndTitle),
            subtitle: Text(l10n.remindersHelpDndBody),
          ),
          SectionHeader(l10n.remindersHelpForYourPhone),
          for (final (brand, brandSteps) in steps)
            ListTile(title: Text(brand), subtitle: Text(brandSteps)),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Text(
              l10n.remindersHelpFooter,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ]),
      ),
    );
  }
}
