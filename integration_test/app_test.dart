import 'package:integration_test/integration_test.dart';

import 'capture_to_restore.dart';

/// On a device: `flutter test integration_test` with a phone connected.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  captureToRestore();
}
