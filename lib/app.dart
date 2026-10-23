import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/providers.dart';
import 'core/router.dart';
import 'core/theme.dart';
import 'domain/enums.dart';
import 'l10n/l10n.dart';
import 'presentation/capture/share_intake.dart';
import 'presentation/shell/scheduler_sync.dart';
import 'presentation/shell/widget_intake.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = buildRouter();
  ref.onDispose(router.dispose);
  return router;
});

class ClearingApp extends ConsumerWidget {
  const ClearingApp({super.key, this.locale, this.debugTextDirection});

  /// Overrides the phone's language; tests use it.
  final Locale? locale;

  /// Forces a reading direction, so tests can check right-to-left layouts
  /// before a right-to-left language ships.
  final TextDirection? debugTextDirection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(settingsProvider).value?.theme;
    return MaterialApp.router(
      title: 'Clearing',
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: switch (theme) {
        ThemePreference.light => ThemeMode.light,
        ThemePreference.dark => ThemeMode.dark,
        ThemePreference.system || null => ThemeMode.system,
      },
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) {
        // Formatting helpers and notifications read the current language.
        setCurrentL10n(context.l10n);
        final app = SchedulerSync(
          child: WidgetIntake(child: ShareIntake(child: child!)),
        );
        return debugTextDirection == null
            ? app
            : Directionality(textDirection: debugTextDirection!, child: app);
      },
    );
  }
}
