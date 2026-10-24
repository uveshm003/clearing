import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/enums.dart';
import '../../domain/grove.dart';
import '../../domain/local_date.dart';
import '../../l10n/l10n.dart';
import '../widgets/empty_state.dart';
import 'grove_scene.dart';

/// Season cards (§6.2): each earlier season's clearing, pressed and kept.
class SeasonAlbumScreen extends ConsumerWidget {
  const SeasonAlbumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inputs = ref.watch(groveInputsProvider);
    final settings = ref.watch(settingsProvider).value;
    final today =
        ref.watch(todayProvider).value ??
        LocalDate.fromDateTime(DateTime.now());
    final l10n = context.l10n;
    final theme = Theme.of(context);
    if (inputs == null || settings == null) return const Scaffold();
    final cards = pastSeasons(inputs, seasonOf(today, inputs.hemisphere));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.groveAlbum)),
      body: cards.isEmpty
          ? EmptyState(
              icon: Icons.photo_album_outlined,
              title: l10n.groveAlbum,
              message: l10n.groveAlbumEmpty,
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
                  child: Text(
                    l10n.groveAlbumHint,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                for (final card in cards)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          GroveScene(
                            grove: card,
                            monsoon:
                                settings.seasonStyle == SeasonStyle.monsoon,
                            interactive: false,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.groveSeasonCard(
                                    _capitalised(
                                      seasonName(
                                        l10n,
                                        card.season.season,
                                        settings.seasonStyle,
                                      ),
                                    ),
                                    '${card.season.start.year}',
                                  ),
                                  style: theme.textTheme.titleMedium,
                                ),
                                Text(
                                  l10n.groveCaption(
                                    seasonName(
                                      l10n,
                                      card.season.season,
                                      settings.seasonStyle,
                                    ),
                                    card.closed,
                                    card.reviews,
                                    card.oldTabs,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  static String _capitalised(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
