import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/glade.dart';
import '../../core/providers.dart';
import '../../core/router.dart';
import '../../domain/item.dart';
import '../../l10n/l10n.dart';
import '../item_commands.dart';
import '../widgets/clearing_art.dart';
import '../widgets/empty_state.dart';
import '../widgets/when_sheet.dart';

enum _Fling { thisWeek, someday, today, delete }

/// Quick decide (§4.3): one inbox item per card. Right is This week, left
/// Someday, up Today, down Delete; a tap opens the full questions. Every
/// direction is also a button, for anyone who'd rather not swipe.
class CardsScreen extends ConsumerStatefulWidget {
  const CardsScreen({super.key});

  @override
  ConsumerState<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends ConsumerState<CardsScreen> {
  Offset _drag = Offset.zero;

  Future<void> _decide(Item item, _Fling fling) async {
    setState(() => _drag = Offset.zero);
    final actions = ref.read(itemActionsProvider);
    switch (fling) {
      case _Fling.thisWeek:
        await ref.plan(item, const WhenThisWeek());
      case _Fling.today:
        await ref.plan(item, const WhenToday());
      case _Fling.someday:
        await actions.moveToSomeday(item);
      case _Fling.delete:
        await ref.trash(context, item);
    }
    if (mounted) {
      SemanticsService.sendAnnouncement(
        View.of(context),
        item.title,
        Directionality.of(context),
      );
    }
  }

  _Fling? _flingFor(Offset drag, Size size) {
    if (drag.dx.abs() > drag.dy.abs()) {
      if (drag.dx > size.width * 0.25) return _Fling.thisWeek;
      if (drag.dx < -size.width * 0.25) return _Fling.someday;
    } else {
      if (drag.dy < -size.height * 0.15) return _Fling.today;
      if (drag.dy > size.height * 0.15) return _Fling.delete;
    }
    return null;
  }

  String _label(_Fling fling) => switch (fling) {
    _Fling.thisWeek => context.l10n.whenThisWeek,
    _Fling.someday => context.l10n.someday,
    _Fling.today => context.l10n.whenToday,
    _Fling.delete => context.l10n.commonDelete,
  };

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(inboxItemsProvider).value ?? const <Item>[];
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final glade = GladeTokens.of(context);
    final size = MediaQuery.sizeOf(context);
    final item = items.firstOrNull;
    final pending = item == null ? null : _flingFor(_drag, size);

    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        title: Text(l10n.cardsTitle),
      ),
      body: item == null
          ? EmptyState(
              icon: Icons.inbox_outlined,
              scene: ClearingScene.nest,
              title: l10n.cardsDone,
            )
          : SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                    child: Text(
                      '${l10n.cardsLeft(items.length)} · ${l10n.cardsHint}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: GestureDetector(
                        onPanUpdate: (d) => setState(() => _drag += d.delta),
                        onPanEnd: (_) {
                          final fling = _flingFor(_drag, size);
                          if (fling == null) {
                            setState(() => _drag = Offset.zero);
                          } else {
                            _decide(item, fling);
                          }
                        },
                        onTap: () => context.push(Routes.clarify(item.id)),
                        child: Transform.translate(
                          offset: _drag,
                          child: Transform.rotate(
                            angle: _drag.dx / 1200,
                            child: Card(
                              key: ValueKey(item.id),
                              color: pending == null
                                  ? theme.colorScheme.surfaceContainer
                                  : theme.colorScheme.primaryContainer,
                              child: SizedBox(
                                width: (size.width - 64).clamp(0, 480),
                                height: 260,
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        item.title,
                                        style: theme.textTheme.headlineSmall,
                                        textAlign: TextAlign.center,
                                      ),
                                      if (pending != null) ...[
                                        const SizedBox(height: 16),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: glade.dawn,
                                            borderRadius:
                                                const BorderRadius.all(
                                                  Radius.circular(12),
                                                ),
                                          ),
                                          child: Text(
                                            _label(pending),
                                            style: theme.textTheme.labelLarge
                                                ?.copyWith(color: glade.onDawn),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final (fling, icon) in [
                          (_Fling.someday, Icons.lightbulb_outline),
                          (_Fling.delete, Icons.delete_outline),
                          (_Fling.today, Icons.wb_sunny_outlined),
                          (_Fling.thisWeek, Icons.view_week_outlined),
                        ])
                          OutlinedButton.icon(
                            icon: Icon(icon),
                            label: Text(_label(fling)),
                            onPressed: () => _decide(item, fling),
                          ),
                        TextButton(
                          onPressed: () =>
                              context.push(Routes.clarify(item.id)),
                          child: Text(l10n.cardsDetails),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
