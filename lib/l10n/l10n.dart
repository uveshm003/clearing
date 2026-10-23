import 'dart:ui';

import 'package:flutter/widgets.dart';

import 'generated/app_localizations.dart';

export 'generated/app_localizations.dart';

/// `context.l10n.someText`: the strings for the app's current language.
extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

AppLocalizations? _current;

/// The current language's strings for code without a [BuildContext]: the
/// formatting helpers, and notifications built in the background. Kept up
/// to date by the app as the language changes.
AppLocalizations get l10n =>
    _current ??
    lookupAppLocalizations(_supported(PlatformDispatcher.instance.locale));

void setCurrentL10n(AppLocalizations strings) => _current = strings;

/// [locale] if the app has it, else English.
Locale _supported(Locale locale) =>
    AppLocalizations.supportedLocales.firstWhere(
      (l) => l.languageCode == locale.languageCode,
      orElse: () => const Locale('en'),
    );
