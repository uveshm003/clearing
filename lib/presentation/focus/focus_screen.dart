import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/glade.dart';
import '../../core/providers.dart';
import '../../domain/enums.dart';
import '../../domain/item.dart';
import '../../l10n/l10n.dart';
import '../item_commands.dart';
import '../widgets/subtask_editor.dart';

/// One item and nothing else (PRD §4.5): its "Done means…", its steps, and
/// two ways out. No timer, nothing tracked.
class FocusScreen extends ConsumerWidget {
  const FocusScreen({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(itemProvider(itemId))) {
      AsyncData(value: final item?) when item.status != ItemStatus.done =>
        _Focus(item: item),
      AsyncData(value: final item?) => _Finished(title: item.title),
      AsyncData() => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(context.l10n.flowItemGone)),
      ),
      _ => const Scaffold(),
    };
  }
}

class _Focus extends ConsumerWidget {
  const _Focus({required this.item});

  final Item item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        title: Text(context.l10n.focusTitle),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                children: [
                  // Almost empty: the one thing, large, in the middle third.
                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.12),
                  Semantics(
                    header: true,
                    child: Text(
                      item.title,
                      style: theme.textTheme.displaySmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (item.doneMeans case final doneMeans?) ...[
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.focusDoneMeans(doneMeans),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SubtaskEditor(itemId: item.id),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(context.l10n.focusNotNow),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.check),
                      label: Text(context.l10n.commonDone),
                      onPressed: () => ref.complete(context, item),
                    ),
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

/// Shown after Done, until the user leaves.
class _Finished extends StatelessWidget {
  const _Finished({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(leading: const CloseButton()),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // The dawn glow: a ring that blooms once around the check.
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: GladeMotion.glow.of(context),
                curve: GladeMotion.glow.curve,
                builder: (context, t, child) => Container(
                  padding: EdgeInsets.all(8 + 10 * t),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: GladeTokens.of(
                      context,
                    ).dawn.withValues(alpha: 0.25 * (1 - t) + 0.12),
                  ),
                  child: child,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 56,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.focusFinishedTitle,
                style: theme.textTheme.displaySmall,
              ),
              const SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center),
              const SizedBox(height: 32),
              FilledButton.tonal(
                onPressed: () => Navigator.pop(context),
                child: Text(context.l10n.commonBack),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
