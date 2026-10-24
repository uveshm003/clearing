import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/glade.dart';
import '../../l10n/l10n.dart';
import 'guides.dart';

/// What a coach mark can point at in the shell.
enum CoachTarget { capture, inbox, today, upcoming, lists }

/// Keys on the shell's widgets, so a coach mark can find them.
final coachKeys = {for (final t in CoachTarget.values) t: GlobalKey()};

/// The coach mark showing now, if any.
final coachProvider = NotifierProvider<Coach, CoachTarget?>(Coach.new);

class Coach extends Notifier<CoachTarget?> {
  @override
  CoachTarget? build() => null;

  void show(CoachTarget target) => state = target;

  void dismiss() => state = null;
}

/// Where each guide's "Show me" points (§4.12).
CoachTarget coachFor(GuideTopic topic) => switch (topic) {
  GuideTopic.capture => CoachTarget.capture,
  GuideTopic.decide => CoachTarget.inbox,
  GuideTopic.today || GuideTopic.review => CoachTarget.today,
  GuideTopic.time => CoachTarget.upcoming,
  GuideTopic.organize || GuideTopic.data => CoachTarget.lists,
};

String _text(AppLocalizations l, CoachTarget target) => switch (target) {
  CoachTarget.capture => l.coachCapture,
  CoachTarget.inbox => l.coachInbox,
  CoachTarget.today => l.coachToday,
  CoachTarget.upcoming => l.coachUpcoming,
  CoachTarget.lists => l.coachLists,
};

/// Dims the shell except for one control, with a line about it: the help
/// centre's guides, shown on the real screen.
class CoachOverlay extends ConsumerWidget {
  const CoachOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final target = ref.watch(coachProvider);
    if (target == null) return const SizedBox.shrink();
    final box = coachKeys[target]!.currentContext?.findRenderObject();
    final overlay = context.findRenderObject();
    if (box is! RenderBox || overlay is! RenderBox || !box.hasSize) {
      return const SizedBox.shrink();
    }
    final topLeft = box.localToGlobal(Offset.zero, ancestor: overlay);
    final hole = (topLeft & box.size).inflate(10);
    final theme = Theme.of(context);
    final text = _text(context.l10n, target);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SemanticsService.sendAnnouncement(
        View.of(context),
        text,
        Directionality.of(context),
      );
    });
    final size = overlay.size;
    final above = hole.center.dy > size.height / 2;
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => ref.read(coachProvider.notifier).dismiss(),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _Scrim(
                  hole: hole,
                  colour: theme.colorScheme.scrim.withValues(alpha: 0.6),
                  ring: GladeTokens.of(context).dawn,
                ),
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              top: above ? null : hole.bottom + 16,
              bottom: above ? size.height - hole.top + 16 : null,
              child: Material(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: const BorderRadius.all(
                  Radius.circular(GladeSpace.pebble),
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 8, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(text, style: theme.textTheme.bodyLarge),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton(
                          onPressed: () =>
                              ref.read(coachProvider.notifier).dismiss(),
                          child: Text(context.l10n.coachGotIt),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Scrim extends CustomPainter {
  _Scrim({required this.hole, required this.colour, required this.ring});

  final Rect hole;
  final Color colour;
  final Color ring;

  @override
  void paint(Canvas canvas, Size size) {
    final shape = RRect.fromRectAndRadius(hole, const Radius.circular(24));
    canvas
      ..drawPath(
        Path.combine(
          PathOperation.difference,
          Path()..addRect(Offset.zero & size),
          Path()..addRRect(shape),
        ),
        Paint()..color = colour,
      )
      ..drawRRect(
        shape,
        Paint()
          ..color = ring
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
  }

  @override
  bool shouldRepaint(_Scrim old) =>
      old.hole != hole || old.colour != colour || old.ring != ring;
}
