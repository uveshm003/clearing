import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/glade.dart';
import '../../core/providers.dart';
import '../../domain/field_notes.dart';
import '../../l10n/l10n.dart';
import 'field_note_text.dart';

/// The notebook of field notes (§6.6). Found ones in full; the rest as soft
/// silhouettes with a hint, which teach what the app can do. No counts.
class FieldNotesScreen extends ConsumerWidget {
  const FieldNotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final found = ref.watch(settingsProvider).value?.fieldNotes ?? const {};
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final glade = GladeTokens.of(context);
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.fieldNotesTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
            child: Text(
              l10n.fieldNotesHint,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          for (final note in FieldNote.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: found.contains(note.name)
                        ? glade.dawn.withValues(alpha: 0.3)
                        : scheme.surfaceContainerHigh,
                    foregroundColor: found.contains(note.name)
                        ? scheme.onSurface
                        : scheme.outline,
                    child: Icon(note.icon),
                  ),
                  title: Text(
                    note.title(l10n),
                    style: found.contains(note.name)
                        ? null
                        : TextStyle(color: scheme.onSurfaceVariant),
                  ),
                  subtitle: Text(
                    found.contains(note.name)
                        ? note.body(l10n)
                        : l10n.fieldNoteLocked(note.hint(l10n)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
