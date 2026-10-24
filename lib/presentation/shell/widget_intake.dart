import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../../app.dart';
import '../../core/router.dart';
import '../../data/home_widgets.dart';
import '../capture/capture_sheet.dart';
import '../guidance/field_notes_hooks.dart';

/// Opens what a home-screen widget was tapped for (FR-14): quick capture,
/// Today, or one item. Check marks are handled in the background instead,
/// by `onWidgetAction`.
class WidgetIntake extends ConsumerStatefulWidget {
  const WidgetIntake({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<WidgetIntake> createState() => _WidgetIntakeState();
}

class _WidgetIntakeState extends ConsumerState<WidgetIntake> {
  StreamSubscription<Uri?>? _clicks;

  bool get _supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  void initState() {
    super.initState();
    if (!_supported) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        _open(await HomeWidget.initiallyLaunchedFromHomeWidget());
        _clicks = HomeWidget.widgetClicked.listen(_open);
      } on MissingPluginException {
        // No Android host, e.g. in tests.
      }
    });
  }

  @override
  void dispose() {
    _clicks?.cancel();
    super.dispose();
  }

  void _open(Uri? uri) {
    final router = ref.read(routerProvider);
    switch (WidgetLink.parse(uri)) {
      case CaptureLink(:final listen):
        router.go(Routes.today);
        noteFieldNote(ref, FieldNote.fromTheDoorstep);
        final context = rootNavigatorKey.currentContext;
        if (context != null) showCaptureSheet(context, listen: listen);
      case ReviewLink():
        router.push(Routes.review);
      case ResetLink():
        router.push(Routes.reset);
      case InboxLink():
        router.go(Routes.inbox);
      case GroveLink():
        router.push(Routes.grove);
      case TodayLink():
        router.go(Routes.today);
      case ItemLink(:final id):
        router.push(Routes.item(id));
      case CompleteLink() || null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
