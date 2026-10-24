import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/providers.dart';
import '../../core/router.dart';
import '../../l10n/l10n.dart';

/// "What's new" (§4.12): the release notes are bundled in the app, since it
/// can't fetch them. Shown once after an update, and from Settings › Help.
Future<void> showWhatsNew(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (sheetContext) {
    final l10n = sheetContext.l10n;
    final points = [
      (Icons.edit_note, l10n.whatsNew1Title, l10n.whatsNew1Body, null),
      (Icons.select_all, l10n.whatsNew2Title, l10n.whatsNew2Body, Routes.inbox),
      (
        Icons.park_outlined,
        l10n.whatsNew3Title,
        l10n.whatsNew3Body,
        Routes.grove,
      ),
      (
        Icons.backup_outlined,
        l10n.whatsNew4Title,
        l10n.whatsNew4Body,
        Routes.backup,
      ),
    ];
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.whatsNewTitle,
              style: Theme.of(sheetContext).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            for (final (icon, title, body, route) in points)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(icon),
                title: Text(title),
                subtitle: Text(body),
                trailing: route == null
                    ? null
                    : TextButton(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          route == Routes.inbox
                              ? context.go(route)
                              : context.push(route);
                        },
                        child: Text(l10n.whatsNewTry),
                      ),
              ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => Navigator.pop(sheetContext),
              child: Text(l10n.commonOk),
            ),
          ],
        ),
      ),
    );
  },
);

/// Shows "What's new" once after an update. A first install just notes the
/// version: the welcome covers everything.
class WhatsNewWatcher extends ConsumerStatefulWidget {
  const WhatsNewWatcher({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<WhatsNewWatcher> createState() => _WhatsNewWatcherState();
}

class _WhatsNewWatcherState extends ConsumerState<WhatsNewWatcher> {
  var _checked = false;

  Future<void> _check() async {
    _checked = true;
    final String version;
    try {
      version = (await PackageInfo.fromPlatform()).version;
    } on Exception {
      return;
    } on Error {
      // No platform in tests.
      return;
    }
    final repository = ref.read(settingsRepositoryProvider);
    final settings = await repository.get();
    if (settings.lastSeenVersion == version) return;
    await repository.save(settings.copyWith(lastSeenVersion: () => version));
    final upgraded =
        settings.lastSeenVersion != null || settings.onboardingDone;
    if (upgraded && mounted) await showWhatsNew(context);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider).value;
    if (!_checked && settings != null && settings.onboardingDone) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _check());
    }
    return widget.child;
  }
}
