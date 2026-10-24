import 'app_settings.dart';

/// Features still being built, off unless switched on from the developer
/// screen in a debug build (§8). Ship them dark, finish them, then remove
/// the flag. None are open right now.
enum FeatureFlag {
  /// Placeholder kept so the screen and the mechanism stay tested.
  example('example', 'An example flag, for testing the switch itself');

  const FeatureFlag(this.key, this.description);

  final String key;
  final String description;
}

extension FeatureFlags on AppSettings {
  bool flag(FeatureFlag flag) => flags.contains(flag.key);
}
