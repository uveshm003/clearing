import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../data/settings_repository.dart';
import '../../domain/field_notes.dart';

export '../../domain/field_notes.dart';

/// The field note just found, for the shell to show once. Only set while
/// the Grove is on.
final foundFieldNoteProvider = NotifierProvider<FoundFieldNote, FieldNote?>(
  FoundFieldNote.new,
);

class FoundFieldNote extends Notifier<FieldNote?> {
  @override
  FieldNote? build() => null;

  void show(FieldNote note) => state = note;

  void dismiss() => state = null;
}

/// Records [note] the first time it happens. Notes are kept even with the
/// Grove off (they're just a set of names), so turning it on later shows
/// what was already found; the little card only shows while it's on.
Future<void> noteFieldNote(WidgetRef ref, FieldNote note) => recordFieldNote(
  ref.read(settingsRepositoryProvider),
  note,
  onNew: (on) {
    if (on) ref.read(foundFieldNoteProvider.notifier).show(note);
  },
);

/// [noteFieldNote] for code with a [Ref] rather than a widget.
Future<void> noteFieldNoteFrom(Ref ref, FieldNote note) => recordFieldNote(
  ref.read(settingsRepositoryProvider),
  note,
  onNew: (on) {
    if (on) ref.read(foundFieldNoteProvider.notifier).show(note);
  },
);

/// Adds [note] to the settings unless it's there; [onNew] is told whether
/// the Grove is on.
Future<void> recordFieldNote(
  SettingsRepository settingsRepository,
  FieldNote note, {
  void Function(bool groveOn)? onNew,
}) async {
  final settings = await settingsRepository.get();
  if (settings.fieldNotes.contains(note.name)) return;
  await settingsRepository.save(
    settings.copyWith(fieldNotes: {...settings.fieldNotes, note.name}),
  );
  onNew?.call(settings.groveEnabled);
}
