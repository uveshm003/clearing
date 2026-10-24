import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/item.dart';
import '../../l10n/l10n.dart';

/// "Plan your day?" (§4.2): pick up to the must-do cap from This week, and
/// they move to Today. The rest stays where it is.
Future<void> showPlanDaySheet(BuildContext context, List<Item> thisWeek) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _PlanDaySheet(items: thisWeek),
    );

class _PlanDaySheet extends ConsumerStatefulWidget {
  const _PlanDaySheet({required this.items});

  final List<Item> items;

  @override
  ConsumerState<_PlanDaySheet> createState() => _PlanDaySheetState();
}

class _PlanDaySheetState extends ConsumerState<_PlanDaySheet> {
  final _picked = <String>[];
  bool _mustDo = false;

  @override
  Widget build(BuildContext context) {
    final cap = ref.watch(settingsProvider).value?.mustDoCap ?? 3;
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
            child: Text(
              l10n.planDayTitle(cap),
              style: theme.textTheme.titleLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              l10n.planDayHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final item in widget.items)
                  CheckboxListTile(
                    value: _picked.contains(item.id),
                    title: Text(item.title),
                    onChanged:
                        !_picked.contains(item.id) && _picked.length >= cap
                        ? null
                        : (v) => setState(
                            () => v == true
                                ? _picked.add(item.id)
                                : _picked.remove(item.id),
                          ),
                  ),
              ],
            ),
          ),
          SwitchListTile(
            title: Text(l10n.planDayMustDo),
            value: _mustDo,
            onChanged: _picked.isEmpty
                ? null
                : (v) => setState(() => _mustDo = v),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: OverflowBar(
              alignment: MainAxisAlignment.end,
              spacing: 8,
              children: [
                TextButton(
                  onPressed: () async {
                    final repository = ref.read(settingsRepositoryProvider);
                    final navigator = Navigator.of(context);
                    final latest = await repository.get();
                    await repository.save(latest.copyWith(planMyDay: false));
                    navigator.pop();
                  },
                  child: Text(l10n.planDayNever),
                ),
                FilledButton(
                  onPressed: _picked.isEmpty
                      ? null
                      : () async {
                          final actions = ref.read(itemActionsProvider);
                          final navigator = Navigator.of(context);
                          final open =
                              ref.read(openItemsProvider).value ?? const [];
                          for (final (i, id) in _picked.indexed) {
                            final item = widget.items.firstWhere(
                              (x) => x.id == id,
                            );
                            final planned = await actions.planToday(item);
                            if (i == 0 && _mustDo) {
                              await actions.setMustDo(
                                planned,
                                openItems: open,
                                cap: cap,
                              );
                            }
                          }
                          navigator.pop();
                        },
                  child: Text(l10n.planDayStart),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
