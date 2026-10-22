import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/enums.dart';
import '../../domain/item.dart';
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
        body: const Center(child: Text('This item no longer exists.')),
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
      appBar: AppBar(leading: const CloseButton(), title: const Text('Focus')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      item.title,
                      style: theme.textTheme.headlineMedium,
                    ),
                  ),
                  if (item.doneMeans case final doneMeans?) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Done means: $doneMeans',
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
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Not now'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text('Done'),
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
              Icon(
                Icons.check_circle_outline,
                size: 56,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text('One less thing', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center),
              const SizedBox(height: 32),
              FilledButton.tonal(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
