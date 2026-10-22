import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../core/router.dart';
import 'capture_sheet.dart';

/// Opens quick capture pre-filled with text shared from another app (FR-01).
///
/// The Android side lives in `MainActivity.kt`: shared text that launched the
/// app is fetched once on start, later shares arrive as `sharedText` calls.
class ShareIntake extends StatefulWidget {
  const ShareIntake({super.key, required this.child});

  final Widget child;

  static const channel = MethodChannel('clearing/share');

  @override
  State<ShareIntake> createState() => _ShareIntakeState();
}

class _ShareIntakeState extends State<ShareIntake> {
  bool get _supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  void initState() {
    super.initState();
    if (!_supported) return;
    ShareIntake.channel.setMethodCallHandler((call) async {
      if (call.method == 'sharedText' && call.arguments is String) {
        _open(call.arguments as String);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final text = await ShareIntake.channel.invokeMethod<String>(
          'takeSharedText',
        );
        if (text != null) _open(text);
      } on MissingPluginException {
        // No Android host, e.g. in tests: nothing was shared.
      }
    });
  }

  @override
  void dispose() {
    if (_supported) ShareIntake.channel.setMethodCallHandler(null);
    super.dispose();
  }

  void _open(String text) {
    final context = rootNavigatorKey.currentContext;
    if (context != null && text.trim().isNotEmpty) {
      showCaptureSheet(context, initialText: text.trim());
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
