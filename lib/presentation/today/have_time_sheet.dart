import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/router.dart';
import '../../domain/enums.dart';
import '../../domain/item.dart';
import '../../domain/today_rules.dart';
import '../../l10n/l10n.dart';
import '../format.dart';

/// "I have a few minutes…" (§5.3): pick a length and, if you like, where
/// you are; up to five things that fit, Today's first, then This week, then
/// Anytime. Pick one to focus on it.
Future<void> showHaveTimeSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _HaveTimeSheet(),
    );

class _HaveTimeSheet extends ConsumerStatefulWidget {
  const _HaveTimeSheet();

  @override
  ConsumerState<_HaveTimeSheet> createState() => _HaveTimeSheetState();
}

class _HaveTimeSheetState extends ConsumerState<_HaveTimeSheet> {
  int _minutes = 15;
  String? _context;

  int _rank(Item item) {
    final today = ref.read(todayProvider).value;
    if (today != null && isOnToday(item, today)) return 0;
    return switch (item.when) {
      When.thisWeek => 1,
      When.onDate => 2,
      _ => 3,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final contexts = ref.watch(contextsProvider).value ?? const [];
    final byItem = ref.watch(itemContextsProvider).value ?? const {};
    final today = ref.watch(todayProvider).value;
    final open = ref.watch(openItemsProvider).value ?? const <Item>[];
    final fits = [
      for (final item in open)
        if (item.status == ItemStatus.active &&
            item.effort != null &&
            item.effort! <= _minutes &&
            (item.doDate == null ||
                today == null ||
                !item.doDate!.isAfter(today.addDays(7))) &&
            (_context == null ||
                (byItem[item.id]?.contains(_context) ?? false)))
          item,
    ]..sort((a, b) => _rank(a).compareTo(_rank(b)));

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(l10n.haveTimeTitle, style: theme.textTheme.titleLarge),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              children: [
                for (final minutes in Item.effortSteps.take(4))
                  ChoiceChip(
                    label: Text(effortLabel(minutes)),
                    selected: _minutes == minutes,
                    onSelected: (_) => setState(() => _minutes = minutes),
                  ),
              ],
            ),
          ),
          if (contexts.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
              child: Text(
                l10n.haveTimeWhere,
                style: theme.textTheme.labelLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(l10n.haveTimeAnywhere),
                    selected: _context == null,
                    onSelected: (_) => setState(() => _context = null),
                  ),
                  for (final c in contexts)
                    ChoiceChip(
                      label: Text(contextLabel(c)),
                      selected: _context == c.id,
                      onSelected: (_) => setState(() => _context = c.id),
                    ),
                ],
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
            child: Text(
              l10n.haveTimeResults,
              style: theme.textTheme.labelLarge,
            ),
          ),
          if (fits.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Text(l10n.haveTimeNone),
            )
          else
            for (final item in fits.take(5))
              ListTile(
                title: Text(item.title),
                subtitle: Text(effortLabel(item.effort!)),
                trailing: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push(Routes.focus(item.id));
                  },
                  child: Text(l10n.haveTimeFocus),
                ),
              ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
