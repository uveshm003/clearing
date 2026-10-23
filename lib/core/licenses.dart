import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Adds the bundled fonts' licences to "Open-source licences" (the SIL Open
/// Font License asks for its text to travel with the fonts).
void registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final (package, file) in const [
      ('Fraunces', 'Fraunces_LICENSE.txt'),
      ('Atkinson Hyperlegible Next', 'AtkinsonHyperlegibleNext_LICENSE.txt'),
      ('Roboto', 'Roboto_LICENSE.txt'),
    ]) {
      yield LicenseEntryWithLineBreaks([
        package,
      ], await rootBundle.loadString('assets/fonts/$file'));
    }
  });
}
