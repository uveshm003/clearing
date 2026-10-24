import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/router.dart';
import '../../domain/enums.dart';
import '../../domain/grove.dart';
import '../../domain/local_date.dart';
import '../../l10n/l10n.dart';
import '../format.dart';
import '../guidance/field_notes_hooks.dart';
import '../widgets/pebble.dart';
import '../widgets/section_header.dart';
import 'grove_scene.dart';

/// "Your clearing" (§6.3): this season's Grove, what each part was for, and
/// the way to the field notes, the cairn and the season cards.
class GroveScreen extends ConsumerStatefulWidget {
  const GroveScreen({super.key});

  @override
  ConsumerState<GroveScreen> createState() => _GroveScreenState();
}

class _GroveScreenState extends ConsumerState<GroveScreen> {
  GroveElement? _tapped;

  @override
  Widget build(BuildContext context) {
    // Notes the Grove can see for itself: an old tab closed, an open sky.
    ref.listen(groveInputsProvider, (_, inputs) {
      if (inputs == null) return;
      for (final note in derivedFieldNotes(inputs)) {
        noteFieldNote(ref, note);
      }
    });
    final grove = ref.watch(groveProvider);
    final settings = ref.watch(settingsProvider).value;
    final today =
        ref.watch(todayProvider).value ??
        LocalDate.fromDateTime(DateTime.now());
    final journal = ref.watch(journalProvider).value ?? const [];
    final theme = Theme.of(context);
    final l10n = context.l10n;
    if (grove == null || settings == null) return const Scaffold();
    final style = settings.seasonStyle;
    final tapped = _tapped;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.groveTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: InteractiveViewer(
                maxScale: 3,
                child: GroveScene(
                  grove: grove,
                  monsoon: style == SeasonStyle.monsoon,
                  onTap: (element) => setState(() => _tapped = element),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Text(
              grove.isEmpty
                  ? l10n.groveEmpty
                  : l10n.groveCaption(
                      seasonName(l10n, grove.season.season, style),
                      grove.closed,
                      grove.reviews,
                      grove.oldTabs,
                    ),
              style: theme.textTheme.titleMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Semantics(
              liveRegion: true,
              child: Text(
                tapped == null
                    ? l10n.groveTapHint
                    : describeElement(l10n, tapped, groveDateLabel(today)),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          SectionHeader(l10n.groveMore),
          Pebble(
            children: [
              ListTile(
                leading: const Icon(Icons.menu_book_outlined),
                title: Text(l10n.fieldNotesTitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.fieldNotes),
              ),
              ListTile(
                leading: const Icon(Icons.layers_outlined),
                title: Text(l10n.groveCairnTitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.cairn),
              ),
              ListTile(
                leading: const Icon(Icons.photo_album_outlined),
                title: Text(l10n.groveAlbum),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.seasons),
              ),
              ListTile(
                leading: const Icon(Icons.insights_outlined),
                title: Text(l10n.insightsTitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.insights),
              ),
            ],
          ),
          SectionHeader(l10n.groveJournal),
          Pebble(
            children: [
              if (journal.isEmpty)
                ListTile(title: Text(l10n.groveJournalEmpty))
              else
                for (final entry in journal.take(20))
                  ListTile(
                    leading: const Icon(Icons.favorite_border),
                    title: Text(entry.body),
                    subtitle: Text(dateLabel(entry.date, today)),
                  ),
            ],
          ),
          SectionHeader(l10n.groveSettings),
          Pebble(
            children: [
              RadioGroup<Hemisphere>(
                groupValue: settings.hemisphere,
                onChanged: (value) {
                  if (value == null) return;
                  ref
                      .read(settingsRepositoryProvider)
                      .save(settings.copyWith(hemisphere: value));
                },
                child: Column(
                  children: [
                    for (final (value, label) in [
                      (Hemisphere.north, l10n.groveNorth),
                      (Hemisphere.south, l10n.groveSouth),
                    ])
                      RadioListTile<Hemisphere>(
                        value: value,
                        title: Text(label),
                      ),
                  ],
                ),
              ),
              SwitchListTile(
                title: Text(l10n.groveWetSeason),
                value: style == SeasonStyle.monsoon,
                onChanged: (v) => ref
                    .read(settingsRepositoryProvider)
                    .save(
                      settings.copyWith(
                        seasonStyle: v
                            ? SeasonStyle.monsoon
                            : SeasonStyle.spring,
                      ),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
