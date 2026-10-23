import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/router.dart';
import '../../core/glade.dart';
import '../../domain/enums.dart';
import '../../domain/item.dart';
import '../../domain/local_date.dart';
import '../../domain/reset_rules.dart';
import '../../domain/review_session.dart';
import '../../domain/today_rules.dart';
import '../widgets/flow_step.dart';
import '../widgets/step_trail.dart';

enum _Step { mind, today, week, letGo, smallest }

/// The overwhelm reset (FR-12, PRD §4.4): five short steps that end on the
/// focus view with a single item. Each step's choices are saved on Next.
class ResetScreen extends ConsumerStatefulWidget {
  const ResetScreen({super.key});

  @override
  ConsumerState<ResetScreen> createState() => _ResetScreenState();
}

class _ResetScreenState extends ConsumerState<ResetScreen> {
  var _step = _Step.mind;
  ReviewSession? _session;
  final _today = <String>{};
  final _week = <String>{};
  final _letGo = <String>{};
  String? _focusId;
  final _firstStep = TextEditingController();
  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    ref
        .read(reviewRepositoryProvider)
        .start(ReviewKind.reset)
        .then((s) => _session = s);
  }

  @override
  void dispose() {
    _firstStep.dispose();
    super.dispose();
  }

  LocalDate get _date =>
      ref.read(todayProvider).value ?? LocalDate.fromDateTime(DateTime.now());

  List<Item> get _candidates => [
    for (final item in ref.read(openItemsProvider).value ?? const <Item>[])
      if (isResetCandidate(item, _date)) item,
  ];

  /// What's left after Today and This week were chosen.
  List<Item> get _rest => [
    for (final item in _candidates)
      if (!_today.contains(item.id) && !_week.contains(item.id)) item,
  ];

  Future<void> _tally(String key, int by) async {
    final session = _session;
    if (session == null || by == 0) return;
    _session = await ref
        .read(reviewRepositoryProvider)
        .save(session.tally(key, by).copyWith(step: _step.index));
  }

  Future<void> _next() async {
    final reset = ref.read(resetActionsProvider);
    switch (_step) {
      case _Step.mind:
        // Pre-tick what is already a must-do or set for this week.
        if (!_seeded) {
          _seeded = true;
          for (final item in _candidates) {
            if (mustDoByDefault(item, _date)) _today.add(item.id);
            if (isThisWeek(item)) _week.add(item.id);
          }
          _week.removeAll(_today);
        }
      case _Step.today:
        await reset.mustHappenToday(_candidates, _today);
        await _tally('today', _today.length);
      case _Step.week:
        _week.removeAll(_today);
        await reset.thisWeek(_candidates, _week);
        await _tally('week', _week.length);
        _letGo
          ..clear()
          ..addAll([
            for (final item in _rest)
              if (letGoByDefault(item)) item.id,
          ]);
      case _Step.letGo:
      case _Step.smallest:
        break;
    }
    if (!mounted) return;
    setState(() => _step = _Step.values[_step.index + 1]);
  }

  Future<void> _applyLetGo({required bool delete}) async {
    final items = [
      for (final item in _rest)
        if (_letGo.contains(item.id)) item,
    ];
    await ref.read(resetActionsProvider).letGo(items, delete: delete);
    await _tally('letGo', items.length);
    await _next();
  }

  Future<void> _finish() async {
    final id = _focusId;
    final item = _candidates.where((i) => i.id == id).firstOrNull;
    final step = _firstStep.text.trim();
    if (item != null && step.isNotEmpty) {
      await ref.read(resetActionsProvider).addFirstStep(item, step);
    }
    if (_session case final session?) {
      await ref
          .read(reviewRepositoryProvider)
          .save(
            session.copyWith(
              step: _step.index,
              completedAt: ref.read(clockProvider)(),
            ),
          );
    }
    if (!mounted) return;
    if (item != null) {
      context.pushReplacement(Routes.focus(item.id));
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild as items change, e.g. after capturing in step one.
    ref.watch(openItemsProvider);
    final step = _step;
    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        title: const Text('Reset'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(22),
          child: StepTrail(count: _Step.values.length, current: step.index),
        ),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: KeyedSubtree(
            key: ValueKey(step),
            child: switch (step) {
              _Step.mind => _mind(),
              _Step.today => _chooseToday(),
              _Step.week => _chooseWeek(),
              _Step.letGo => _chooseLetGo(),
              _Step.smallest => _smallest(),
            },
          ),
        ),
      ),
    );
  }

  Widget _nextButton({String label = 'Next'}) =>
      FilledButton(onPressed: _next, child: Text(label));

  Widget _mind() {
    final open = _candidates;
    final theme = Theme.of(context);
    return FlowStep(
      question: 'Everything on your mind',
      hint:
          'Get it all out, one thought at a time. Nothing needs deciding yet.',
      actions: [_nextButton()],
      children: [
        BurstCapture(onSaved: (n) => _tally('captured', n)),
        if (open.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('Already on your plate', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          for (final item in open)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                item.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _checklist(List<Item> items, Set<String> chosen, {int? limit}) =>
      Column(
        children: [
          for (final item in items)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              // What isn't chosen fades back, so the screen literally clears.
              title: AnimatedDefaultTextStyle(
                duration: GladeMotion.settle.of(context),
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: chosen.contains(item.id)
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                child: Text(item.title),
              ),
              value: chosen.contains(item.id),
              onChanged:
                  !chosen.contains(item.id) &&
                      limit != null &&
                      chosen.length >= limit
                  ? null
                  : (on) => setState(
                      () => on! ? chosen.add(item.id) : chosen.remove(item.id),
                    ),
            ),
        ],
      );

  Widget _chooseToday() {
    final cap = ref.read(settingsProvider).value?.mustDoCap ?? 3;
    final items = _candidates;
    return FlowStep(
      question: 'What must happen today?',
      hint: 'Up to $cap. Only what truly can’t wait.',
      actions: [_nextButton()],
      children: [
        if (items.isEmpty) const Text('Nothing open right now.'),
        _checklist(items, _today, limit: cap),
      ],
    );
  }

  Widget _chooseWeek() {
    final items = [
      for (final item in _candidates)
        if (!_today.contains(item.id)) item,
    ];
    return FlowStep(
      question: 'What belongs to this week?',
      hint: 'It stays visible as one quiet row on Today.',
      actions: [_nextButton()],
      children: [
        if (items.isEmpty) const Text('Nothing else is open.'),
        _checklist(items, _week),
      ],
    );
  }

  Widget _chooseLetGo() {
    final items = _rest;
    return FlowStep(
      question: 'Let go of the rest?',
      hint: items.isEmpty
          ? 'Nothing left over.'
          : 'Ticked items go to Someday, or to Trash for 30 days. Untick '
                'anything you want to keep as it is.',
      actions: [
        TextButton(onPressed: _next, child: const Text('Keep them all')),
        if (_letGo.isNotEmpty) ...[
          OutlinedButton(
            onPressed: () => _applyLetGo(delete: true),
            child: const Text('Delete'),
          ),
          FilledButton(
            onPressed: () => _applyLetGo(delete: false),
            child: const Text('Move to Someday'),
          ),
        ],
      ],
      children: [_checklist(items, _letGo)],
    );
  }

  Widget _smallest() {
    final chosen = [
      for (final item in _candidates)
        if (_today.contains(item.id) || _week.contains(item.id)) item,
    ];
    _focusId ??= chosen.firstOrNull?.id;
    return FlowStep(
      question: 'Smallest next action',
      hint: chosen.isEmpty
          ? 'Nothing was picked, and that’s fine. You’ve cleared some space.'
          : 'Pick one. Optionally, name a first step so small it’s easy.',
      actions: [
        FilledButton(
          onPressed: _finish,
          child: Text(chosen.isEmpty ? 'Finish' : 'Focus on it'),
        ),
      ],
      children: [
        RadioGroup<String>(
          groupValue: _focusId,
          onChanged: (id) => setState(() => _focusId = id),
          child: Column(
            children: [
              for (final item in chosen)
                RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  value: item.id,
                  title: Text(item.title),
                ),
            ],
          ),
        ),
        if (chosen.isNotEmpty) ...[
          const SizedBox(height: 16),
          TextField(
            controller: _firstStep,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Tiny first step (optional)',
              hintText: 'e.g. “open the letter”',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ],
    );
  }
}
