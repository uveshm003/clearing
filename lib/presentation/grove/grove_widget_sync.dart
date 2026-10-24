import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/glade.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../domain/enums.dart';
import '../../domain/grove.dart';
import 'grove_painter.dart';

/// Keeps the Grove home-screen widget's picture up to date (§6.3): painted
/// here, in the app, whenever the Grove changes, and handed to the widget
/// as an image. A calm reminder that isn't a notification.
class GroveWidgetSync extends ConsumerStatefulWidget {
  const GroveWidgetSync({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<GroveWidgetSync> createState() => _GroveWidgetSyncState();
}

class _GroveWidgetSyncState extends ConsumerState<GroveWidgetSync> {
  @override
  void initState() {
    super.initState();
    ref.listenManual<GroveState?>(groveProvider, (_, grove) {
      final settings = ref.read(settingsProvider).value;
      if (grove == null || settings == null || !settings.groveEnabled) return;
      _paint(grove, monsoon: settings.seasonStyle == SeasonStyle.monsoon);
    }, fireImmediately: true);
  }

  Future<void> _paint(GroveState grove, {required bool monsoon}) async {
    final dark =
        MediaQuery.maybePlatformBrightnessOf(context) == Brightness.dark;
    final theme = dark ? AppTheme.dark() : AppTheme.light();
    final glade = theme.extension<GladeTokens>()!;
    try {
      await ref
          .read(homeWidgetGatewayProvider)
          .showGrove(
            SizedBox.fromSize(
              size: groveSize,
              child: CustomPaint(
                painter: GrovePainter(
                  placed: layoutGrove(grove),
                  season: grove.season.season,
                  glade: glade,
                  scheme: theme.colorScheme,
                  monsoon: monsoon,
                ),
              ),
            ),
            groveSize,
          );
    } on Exception {
      // No widget host (tests, other platforms): nothing to paint for.
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
