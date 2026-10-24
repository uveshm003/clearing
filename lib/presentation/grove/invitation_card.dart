import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/router.dart';
import '../../domain/grove.dart';
import '../../domain/local_date.dart';
import '../../l10n/l10n.dart';
import '../widgets/pebble.dart';

/// This week's invitation (§6.7): one optional idea, as a quiet row on
/// Today. Taking it up adds a stepping stone to the Grove; ignoring it does
/// nothing, and it goes on its own at the week's end.
class InvitationCard extends ConsumerWidget {
  const InvitationCard({super.key});

  static String text(AppLocalizations l, Invitation invitation) =>
      switch (invitation) {
        Invitation.homeForThree => l.inviteHomeForThree,
        Invitation.doneMeans => l.inviteDoneMeans,
        Invitation.oldThought => l.inviteOldThought,
        Invitation.parkAnIdea => l.inviteParkAnIdea,
        Invitation.tryFocus => l.inviteTryFocus,
        Invitation.tryReset => l.inviteTryReset,
        Invitation.addEffort => l.inviteAddEffort,
        Invitation.backUp => l.inviteBackUp,
      };

  static String? _where(Invitation invitation) => switch (invitation) {
    Invitation.homeForThree || Invitation.parkAnIdea => Routes.inbox,
    Invitation.oldThought => Routes.cairn,
    Invitation.tryReset => Routes.reset,
    Invitation.backUp => Routes.backup,
    _ => null,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).value;
    final today = ref.watch(todayProvider).value;
    if (settings == null ||
        today == null ||
        !settings.groveEnabled ||
        !settings.invitationsEnabled) {
      return const SizedBox.shrink();
    }
    final week = today.startOfWeek(settings.weekStart);
    final invitation = invitationFor(
      weekStart: week,
      found: settings.fieldNotes,
      taken: settings.invitationsDone,
    );
    if (invitation == null) return const SizedBox.shrink();
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final repository = ref.read(settingsRepositoryProvider);

    Future<void> mark(String what) async {
      final latest = await repository.get();
      await repository.save(
        latest.copyWith(
          invitationsDone: {
            ...latest.invitationsDone,
            invitationKey(week, what),
          },
        ),
      );
    }

    final where = _where(invitation);
    return Pebble(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      children: [
        ListTile(
          leading: const Icon(Icons.local_florist_outlined),
          title: Text(l10n.inviteLabel, style: theme.textTheme.labelLarge),
          subtitle: Text(
            text(l10n, invitation),
            style: theme.textTheme.bodyMedium,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
          child: Wrap(
            alignment: WrapAlignment.end,
            children: [
              PopupMenuButton<String>(
                tooltip: l10n.commonMore,
                onSelected: (value) async {
                  if (value == 'off') {
                    final latest = await repository.get();
                    await repository.save(
                      latest.copyWith(invitationsEnabled: false),
                    );
                  } else {
                    await mark('skip');
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'skip',
                    child: Text(l10n.inviteNotThisWeek),
                  ),
                  PopupMenuItem(value: 'off', child: Text(l10n.inviteOff)),
                ],
              ),
              if (where != null)
                TextButton(
                  onPressed: () => where == Routes.inbox
                      ? context.go(where)
                      : context.push(where),
                  child: Text(l10n.inviteGo),
                ),
              TextButton(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final thanks = l10n.inviteThanks;
                  await mark(invitation.name);
                  messenger
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(content: Text(thanks)));
                },
                child: Text(l10n.inviteDidIt),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Whether [week]'s invitation is still to come; for tests.
bool invitationOpen(LocalDate week, Set<String> taken) =>
    !taken.any((t) => t.startsWith('${week.toIso()}:'));
