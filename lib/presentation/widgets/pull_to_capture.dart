import 'package:flutter/material.dart';

import '../../core/glade.dart';
import '../../l10n/l10n.dart';
import '../capture/capture_sheet.dart';

/// Pulling down past the top of a list opens capture: thumb-reachable on
/// tall phones, as well as the button.
class PullToCapture extends StatefulWidget {
  const PullToCapture({super.key, required this.child});

  final Widget child;

  /// How far past the top, in logical pixels, arms it.
  static const threshold = 90.0;

  @override
  State<PullToCapture> createState() => _PullToCaptureState();
}

class _PullToCaptureState extends State<PullToCapture> {
  double _pulled = 0;

  bool get _armed => _pulled >= PullToCapture.threshold;

  bool _onScroll(ScrollNotification n) {
    if (n.depth != 0) return false;
    if (n is OverscrollNotification &&
        n.overscroll < 0 &&
        n.dragDetails != null &&
        n.metrics.pixels <= n.metrics.minScrollExtent) {
      setState(() => _pulled -= n.overscroll);
    } else if (n is ScrollUpdateNotification &&
        n.metrics.pixels < n.metrics.minScrollExtent &&
        n.dragDetails != null) {
      // Bouncing physics report the pull as negative pixels.
      setState(() => _pulled = n.metrics.minScrollExtent - n.metrics.pixels);
    } else if (n is ScrollEndNotification ||
        (n is UserScrollNotification &&
            _pulled > 0 &&
            n.direction.index == 0)) {
      final open = _armed;
      if (_pulled != 0) setState(() => _pulled = 0);
      if (open) showCaptureSheet(context);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: Stack(
        children: [
          widget.child,
          if (_pulled > 8)
            Positioned(
              top: 8,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Center(
                  child: AnimatedOpacity(
                    duration: GladeMotion.settle.of(context),
                    opacity: (_pulled / PullToCapture.threshold).clamp(0, 1),
                    child: Chip(
                      avatar: Icon(
                        _armed ? Icons.edit_note : Icons.arrow_downward,
                        size: 18,
                      ),
                      label: Text(
                        _armed
                            ? context.l10n.pullToCapture
                            : context.l10n.shellCapture,
                        style: theme.textTheme.labelLarge,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
