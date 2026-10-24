import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/glade.dart';
import '../../core/providers.dart';
import '../../domain/enums.dart';
import '../../domain/item.dart';
import '../../core/router.dart';
import '../../l10n/l10n.dart';
import '../guidance/field_notes_hooks.dart';
import '../item_commands.dart';
import '../widgets/subtask_editor.dart';

/// One item and nothing else (PRD §4.5): its smallest first step, its
/// "Done means…", its steps, and two ways out. Nothing is tracked; a soft
/// timebox is there only for those who turn it on in Settings. The screen
/// stays on while it's open.
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

class _Focus extends ConsumerStatefulWidget {
  const _Focus({required this.item});

  final Item item;

  @override
  ConsumerState<_Focus> createState() => _FocusState();
}

class _FocusState extends ConsumerState<_Focus> {
  bool _firstStepDone = false;

  /// The timebox, if one is running: its length and when it started.
  ({Duration length, DateTime started})? _box;
  Timer? _tick;
  late final _device = ref.read(deviceGatewayProvider);

  Item get item => widget.item;

  @override
  void initState() {
    super.initState();
    _device.keepScreenOn(true);
  }

  @override
  void dispose() {
    _tick?.cancel();
    _device.keepScreenOn(false);
    super.dispose();
  }

  void _startBox(int minutes) {
    _tick?.cancel();
    setState(
      () =>
          _box = (length: Duration(minutes: minutes), started: DateTime.now()),
    );
    _tick = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) setState(() {});
    });
  }

  void _stopBox() {
    _tick?.cancel();
    setState(() => _box = null);
  }

  Future<void> _stuck() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                context.l10n.focusStuckTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.checklist),
              title: Text(context.l10n.focusStuckBreak),
              onTap: () => Navigator.pop(context, 'break'),
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: Text(context.l10n.focusStuckDoneMeans),
              onTap: () => Navigator.pop(context, 'done'),
            ),
            ListTile(
              leading: const Icon(Icons.bedtime_outlined),
              title: Text(context.l10n.focusStuckLater),
              onTap: () => Navigator.pop(context, 'later'),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    switch (choice) {
      case 'break':
        await context.push(Routes.item(item.id));
      case 'done':
        final controller = TextEditingController(text: item.doneMeans);
        final value = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(context.l10n.clarifyDoneMeans),
            content: TextField(
              controller: controller,
              autofocus: true,
              maxLines: null,
              decoration: InputDecoration(
                hintText: context.l10n.clarifyDoneMeansExample1,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(context.l10n.commonCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: Text(context.l10n.commonSave),
              ),
            ],
          ),
        );
        controller.dispose();
        if (value != null) {
          await ref
              .read(itemActionsProvider)
              .save(
                item.copyWith(
                  doneMeans: () => value.trim().isEmpty ? null : value.trim(),
                ),
              );
        }
      case 'later':
        if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final glade = GladeTokens.of(context);
    final timebox = ref.watch(settingsProvider).value?.focusTimebox ?? false;
    final box = _box;
    final elapsed = box == null
        ? 0.0
        : (DateTime.now().difference(box.started).inSeconds /
                  box.length.inSeconds)
              .clamp(0.0, 1.0);
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
                  if (box != null) ...[
                    // The sky clears as the minutes pass; no countdown.
                    ClipRRect(
                      borderRadius: BorderRadius.circular(GladeSpace.pebble),
                      child: SizedBox(
                        height: 24,
                        child: ColoredBox(
                          color: glade.sky(
                            remaining: 100 - (elapsed * 100).round(),
                            total: 100,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            elapsed >= 1
                                ? context.l10n.focusTimeboxDone
                                : context.l10n.focusTimeboxRunning,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          tooltip: context.l10n.focusTimeboxStop,
                          onPressed: _stopBox,
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.1),
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
                  // Shown on its own unless it's already the first of the
                  // steps below (the reset adds it as both).
                  if (item.firstStep case final step?
                      when !(ref
                              .watch(subtasksProvider(item.id))
                              .value
                              ?.any((s) => s.title == step) ??
                          false)) ...[
                    const SizedBox(height: 24),
                    Card(
                      color: theme.colorScheme.primaryContainer,
                      child: CheckboxListTile(
                        value: _firstStepDone,
                        title: Text(
                          step,
                          style: theme.textTheme.titleMedium?.copyWith(
                            decoration: _firstStepDone
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        subtitle: Text(
                          _firstStepDone
                              ? context.l10n.focusFirstStepDone
                              : context.l10n.focusFirstStep,
                        ),
                        onChanged: (v) {
                          HapticFeedback.lightImpact();
                          setState(() => _firstStepDone = v ?? false);
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SubtaskEditor(itemId: item.id),
                  if (timebox && box == null) ...[
                    const SizedBox(height: 24),
                    Text(
                      context.l10n.focusTimebox,
                      style: theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final minutes in const [5, 15, 25])
                          ActionChip(
                            label: Text(context.l10n.effortMinutes(minutes)),
                            onPressed: () => _startBox(minutes),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  Align(
                    child: TextButton.icon(
                      icon: const Icon(Icons.help_outline),
                      label: Text(context.l10n.focusStuck),
                      onPressed: _stuck,
                    ),
                  ),
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
                      onPressed: () async {
                        unawaited(noteFieldNote(ref, FieldNote.justOneThing));
                        if (context.mounted) await ref.complete(context, item);
                      },
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
