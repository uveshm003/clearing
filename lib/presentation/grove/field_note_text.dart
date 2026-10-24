import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/glade.dart';
import '../../core/router.dart';
import '../../l10n/l10n.dart';
import '../guidance/field_notes_hooks.dart';

extension FieldNoteText on FieldNote {
  String title(AppLocalizations l) => switch (this) {
    FieldNote.firstLight => l.noteFirstLightName,
    FieldNote.aHomeForEverything => l.noteHomeName,
    FieldNote.outOfYourHands => l.noteHandsName,
    FieldNote.theLongView => l.noteLongViewName,
    FieldNote.deepBreath => l.noteBreathName,
    FieldNote.thePath => l.notePathName,
    FieldNote.justOneThing => l.noteOneThingName,
    FieldNote.safeKeeping => l.noteKeepingName,
    FieldNote.fromTheDoorstep => l.noteDoorstepName,
    FieldNote.oldTab => l.noteOldTabName,
    FieldNote.openSky => l.noteOpenSkyName,
    FieldNote.fourSeasons => l.noteSeasonsName,
  };

  String body(AppLocalizations l) => switch (this) {
    FieldNote.firstLight => l.noteFirstLightBody,
    FieldNote.aHomeForEverything => l.noteHomeBody,
    FieldNote.outOfYourHands => l.noteHandsBody,
    FieldNote.theLongView => l.noteLongViewBody,
    FieldNote.deepBreath => l.noteBreathBody,
    FieldNote.thePath => l.notePathBody,
    FieldNote.justOneThing => l.noteOneThingBody,
    FieldNote.safeKeeping => l.noteKeepingBody,
    FieldNote.fromTheDoorstep => l.noteDoorstepBody,
    FieldNote.oldTab => l.noteOldTabBody,
    FieldNote.openSky => l.noteOpenSkyBody,
    FieldNote.fourSeasons => l.noteSeasonsBody,
  };

  String hint(AppLocalizations l) => switch (this) {
    FieldNote.firstLight => l.noteFirstLightHint,
    FieldNote.aHomeForEverything => l.noteHomeHint,
    FieldNote.outOfYourHands => l.noteHandsHint,
    FieldNote.theLongView => l.noteLongViewHint,
    FieldNote.deepBreath => l.noteBreathHint,
    FieldNote.thePath => l.notePathHint,
    FieldNote.justOneThing => l.noteOneThingHint,
    FieldNote.safeKeeping => l.noteKeepingHint,
    FieldNote.fromTheDoorstep => l.noteDoorstepHint,
    FieldNote.oldTab => l.noteOldTabHint,
    FieldNote.openSky => l.noteOpenSkyHint,
    FieldNote.fourSeasons => l.noteSeasonsHint,
  };

  IconData get icon => switch (this) {
    FieldNote.firstLight => Icons.wb_twilight,
    FieldNote.aHomeForEverything => Icons.home_outlined,
    FieldNote.outOfYourHands => Icons.handshake_outlined,
    FieldNote.theLongView => Icons.repeat,
    FieldNote.deepBreath => Icons.air,
    FieldNote.thePath => Icons.hiking,
    FieldNote.justOneThing => Icons.center_focus_strong_outlined,
    FieldNote.safeKeeping => Icons.shield_outlined,
    FieldNote.fromTheDoorstep => Icons.door_front_door_outlined,
    FieldNote.oldTab => Icons.local_florist_outlined,
    FieldNote.openSky => Icons.wb_sunny_outlined,
    FieldNote.fourSeasons => Icons.park_outlined,
  };
}

/// The small card that says a field note was found: quiet, inline, gone on
/// its own after a few seconds. Never a dialog, never a notification.
class FieldNoteToast extends ConsumerStatefulWidget {
  const FieldNoteToast({super.key});

  @override
  ConsumerState<FieldNoteToast> createState() => _FieldNoteToastState();
}

class _FieldNoteToastState extends ConsumerState<FieldNoteToast> {
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(foundFieldNoteProvider, (_, note) {
      _timer?.cancel();
      if (note == null) return;
      SemanticsService.sendAnnouncement(
        View.of(context),
        context.l10n.fieldNoteFound(
          note.title(context.l10n),
          note.body(context.l10n),
        ),
        Directionality.of(context),
      );
      _timer = Timer(
        const Duration(seconds: 6),
        () => ref.read(foundFieldNoteProvider.notifier).dismiss(),
      );
    });
    final note = ref.watch(foundFieldNoteProvider);
    final theme = Theme.of(context);
    final glade = GladeTokens.of(context);
    return AnimatedSwitcher(
      duration: GladeMotion.settle.of(context),
      child: note == null
          ? const SizedBox.shrink()
          : Padding(
              key: ValueKey(note),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Material(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: const BorderRadius.all(
                  Radius.circular(GladeSpace.pebble),
                ),
                child: InkWell(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(GladeSpace.pebble),
                  ),
                  onTap: () {
                    ref.read(foundFieldNoteProvider.notifier).dismiss();
                    context.push(Routes.fieldNotes);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: glade.dawn.withValues(alpha: 0.3),
                          foregroundColor: theme.colorScheme.onSurface,
                          child: Icon(note.icon),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ExcludeSemantics(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${context.l10n.fieldNoteLabel} · '
                                  '${note.title(context.l10n)}',
                                  style: theme.textTheme.labelLarge,
                                ),
                                Text(
                                  note.body(context.l10n),
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          tooltip: context.l10n.commonClose,
                          onPressed: () => ref
                              .read(foundFieldNoteProvider.notifier)
                              .dismiss(),
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
