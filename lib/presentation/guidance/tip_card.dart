import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/glade.dart';
import '../../core/providers.dart';
import '../../l10n/l10n.dart';

/// The one-time tips, by id. Each shows once, where it matters, until
/// dismissed; Settings › Help can show them all again.
abstract final class Tips {
  static const todayRing = 'today_ring';
  static const inboxSwipe = 'inbox_swipe';
  static const upcomingWeek = 'upcoming_week';
  static const listsBlock = 'lists_block';
  static const itemFocus = 'item_focus';
  static const captureBurst = 'capture_burst';
  static const selectMany = 'select_many';
  static const effort = 'effort';

  // Words testers found confusing, explained once where they first appear.
  static const glossClarify = 'gloss_clarify';
  static const glossMustDo = 'gloss_must_do';
  static const glossCarried = 'gloss_carried';
  static const glossWaiting = 'gloss_waiting';
  static const glossSomeday = 'gloss_someday';
}

/// A one-time hint ("Tips as you go"): a small pebble with a bulb, the hint
/// and "Got it". Nothing shows once it's dismissed or when tips are off.
class TipCard extends ConsumerWidget {
  const TipCard({
    super.key,
    required this.id,
    required this.text,
    this.margin = const EdgeInsets.fromLTRB(16, 0, 16, 12),
  });

  final String id;
  final String text;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).value;
    final visible =
        settings != null &&
        settings.showTips &&
        !settings.seenTips.contains(id);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final glade = GladeTokens.of(context);

    return AnimatedSize(
      duration: GladeMotion.settle.of(context),
      curve: GladeMotion.settle.curve,
      alignment: Alignment.topCenter,
      child: !visible
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: margin,
              child: Semantics(
                container: true,
                child: Material(
                  color: scheme.surfaceContainerHigh,
                  shape: RoundedRectangleBorder(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(GladeSpace.pebble),
                    ),
                    side: BorderSide(color: glade.dawn, width: 1.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 8, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: scheme.primary,
                              semanticLabel: context.l10n.tipLabel,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsetsDirectional.only(
                                  end: 8,
                                ),
                                child: Text(
                                  text,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: TextButton(
                            onPressed: () => ref
                                .read(settingsRepositoryProvider)
                                .save(
                                  settings.copyWith(
                                    seenTips: {...settings.seenTips, id},
                                  ),
                                ),
                            child: Text(context.l10n.tipGotIt),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
