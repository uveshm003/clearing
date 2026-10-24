import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/router.dart';
import '../../domain/enums.dart';
import '../../domain/item.dart';
import '../../domain/local_date.dart';
import '../../domain/review_rules.dart';
import '../../domain/review_session.dart';
import '../../data/device.dart';
import '../../domain/item_list.dart';
import '../../l10n/l10n.dart';
import '../capture/capture_sheet.dart';
import '../format.dart';
import '../guidance/field_notes_hooks.dart';
import '../item_commands.dart';
import 'look_back.dart';
import '../widgets/flow_step.dart';
import '../widgets/step_trail.dart';
import '../widgets/clearing_art.dart';
import '../widgets/when_sheet.dart';

/// Tally keys saved with the session. A summary, never a score.
const _cleared = 'cleared';
const _planned = 'planned';
const _skipped = 'skipped';
const _parked = 'parked';

/// Set on a quick review, so resuming keeps it quick.
const _quick = 'quick';

/// Set once the length was chosen.
const _chosen = 'chosen';

/// The weekly review (FR-11, PRD §4.3). Progress is saved after every step
/// and every decision, so leaving part-way resumes at the same step.
class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  ReviewSession? _session;
  bool _resumed = false;

  /// Inbox items passed over with "Skip for now" during this visit.
  final _skippedIds = <String>{};

  /// Own checks ticked this visit.
  final _checked = <int>{};
  final _wins = TextEditingController();

  @override
  void dispose() {
    _wins.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _open();
  }

  Future<void> _open() async {
    final reviews = ref.read(reviewRepositoryProvider);
    final latest = await reviews.latest(ReviewKind.weekly);
    final now = ref.read(clockProvider)();
    final resume = canResume(latest, now);
    final session = resume ? latest! : await reviews.start(ReviewKind.weekly);
    if (mounted) {
      setState(() {
        _session = session;
        _resumed = resume && session.step > 0;
      });
    }
  }

  List<ReviewStep> get _steps => reviewSteps(
    quick: (_session?.count(_quick) ?? 0) > 0,
    ownChecks:
        ref.read(settingsProvider).value?.reviewPrompts.isNotEmpty ?? false,
  );

  ReviewStep get _step =>
      ReviewStep.values[(_session?.step ?? 0).clamp(
        0,
        ReviewStep.values.length - 1,
      )];

  /// The length was chosen (or the setting chose it).
  bool get _lengthChosen {
    final session = _session;
    if (session == null) return true;
    if (session.count(_chosen) > 0 || session.step > 0) return true;
    return ref.read(settingsProvider).value?.reviewLength != ReviewLength.ask;
  }

  Future<void> _choose({required bool quick}) async {
    final session = _session;
    if (session == null) return;
    var next = session.tally(_chosen);
    if (quick) next = next.tally(_quick);
    final steps = reviewSteps(
      quick: quick,
      ownChecks:
          ref.read(settingsProvider).value?.reviewPrompts.isNotEmpty ?? false,
    );
    await _save(next.copyWith(step: steps.first.index));
  }

  LocalDate get _today =>
      ref.read(todayProvider).value ?? LocalDate.fromDateTime(DateTime.now());

  Future<void> _save(ReviewSession session) async {
    setState(() => _session = session);
    await ref.read(reviewRepositoryProvider).save(session);
  }

  Future<void> _tally(String key) async {
    if (_session case final session?) await _save(session.tally(key));
  }

  Future<void> _go(ReviewStep step) async {
    if (_session case final session?) {
      _resumed = false;
      await _save(session.copyWith(step: step.index));
    }
  }

  Future<void> _next() {
    final steps = _steps;
    final i = steps.indexOf(_step);
    return _go(steps[(i + 1).clamp(0, steps.length - 1)]);
  }

  Future<void> _finish() async {
    final settings = ref.read(settingsProvider).value;
    final wins = _wins.text.trim();
    if (wins.isNotEmpty) {
      await ref.read(journalRepositoryProvider).add(_today, wins);
    }
    if (_session case final session?) {
      await _save(session.copyWith(completedAt: ref.read(clockProvider)()));
    }
    HapticFeedback.mediumImpact();
    if (settings?.sounds ?? false) {
      unawaited(ref.read(deviceGatewayProvider).chime(Chime.review));
    }
    unawaited(noteFieldNote(ref, FieldNote.thePath));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    final step = _step;
    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        title: Text(context.l10n.reviewTitle),
        // "The path": a stone per step, filled as the review goes.
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: StepTrail(
            count: _steps.length,
            current: _steps.indexOf(step).clamp(0, _steps.length - 1),
            stones: true,
          ),
        ),
      ),
      body: session == null
          ? const SizedBox.shrink()
          : SafeArea(
              child: Column(
                children: [
                  if (_resumed)
                    MaterialBanner(
                      content: Text(context.l10n.reviewResumed),
                      actions: [
                        TextButton(
                          onPressed: () => _go(ReviewStep.emptyHead),
                          child: Text(context.l10n.reviewStartOver),
                        ),
                      ],
                    ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: !_lengthChosen
                          ? _length()
                          : KeyedSubtree(
                              key: ValueKey(step),
                              child: switch (step) {
                                ReviewStep.emptyHead => _emptyHead(),
                                ReviewStep.inbox => _inbox(),
                                ReviewStep.lastWeek => _lastWeek(),
                                ReviewStep.waiting => _waiting(),
                                ReviewStep.nextWeek => _nextWeek(),
                                ReviewStep.someday => _someday(),
                                ReviewStep.ownChecks => _ownChecks(),
                                ReviewStep.close => _close(session),
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  /// Quick or full, unless the setting already says.
  Widget _length() => FlowStep(
    question: context.l10n.reviewLengthTitle,
    hint: context.l10n.reviewQuickCounts,
    actions: const [],
    children: [
      ListTile(
        leading: const Icon(Icons.bolt_outlined),
        title: Text(context.l10n.reviewQuick),
        subtitle: Text(context.l10n.reviewQuickHint),
        onTap: () => _choose(quick: true),
      ),
      ListTile(
        leading: const Icon(Icons.hiking),
        title: Text(context.l10n.reviewFull),
        subtitle: Text(context.l10n.reviewFullHint),
        onTap: () => _choose(quick: false),
      ),
    ],
  );

  Widget _ownChecks() {
    final prompts =
        ref.watch(settingsProvider).value?.reviewPrompts ?? const <String>[];
    return FlowStep(
      question: context.l10n.reviewOwnChecks,
      hint: context.l10n.reviewOwnChecksHint,
      actions: [_nextButton()],
      children: [
        for (final (i, prompt) in prompts.indexed)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _checked.contains(i),
            title: Text(prompt),
            onChanged: (v) => setState(
              () => v == true ? _checked.add(i) : _checked.remove(i),
            ),
          ),
      ],
    );
  }

  Widget _nextButton() =>
      FilledButton(onPressed: _next, child: Text(context.l10n.commonNext));

  List<Item> get _openItems => ref.watch(openItemsProvider).value ?? const [];

  Widget _emptyHead() => FlowStep(
    question: context.l10n.reviewEmptyHeadTitle,
    hint: context.l10n.reviewEmptyHeadHint,
    actions: [_nextButton()],
    children: const [BurstCapture()],
  );

  // Step 2: every inbox item gets a decision, one at a time.

  Widget _inbox() {
    final inbox = [
      for (final item in _openItems)
        if (item.status == ItemStatus.inbox && !_skippedIds.contains(item.id))
          item,
    ];
    final item = inbox.firstOrNull;
    if (item == null) {
      return FlowStep(
        question: context.l10n.reviewInboxClearTitle,
        hint: _skippedIds.isEmpty
            ? context.l10n.reviewInboxClearHint
            : context.l10n.reviewInboxSkipped(_skippedIds.length),
        actions: [_nextButton()],
        children: const [],
      );
    }

    Future<void> decide(String key, Future<Object?> Function() change) async {
      await change();
      await _tally(key);
    }

    final actions = ref.read(itemActionsProvider);
    final today = _today;
    return FlowStep(
      question: item.title,
      hint: context.l10n.reviewInboxLeft(inbox.length),
      actions: [
        TextButton(
          onPressed: () async {
            setState(() => _skippedIds.add(item.id));
            await _tally(_skipped);
          },
          child: Text(context.l10n.reviewSkipForNow),
        ),
      ],
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _choice(
              Icons.wb_sunny_outlined,
              context.l10n.whenToday,
              () => decide(_planned, () => actions.planToday(item)),
            ),
            _choice(
              Icons.view_week_outlined,
              context.l10n.whenThisWeek,
              () => decide(_planned, () => actions.planThisWeek(item)),
            ),
            _choice(Icons.event_outlined, context.l10n.whenPickDate, () async {
              final picked = await pickDate(context, today: today);
              if (picked != null) {
                await decide(
                  _planned,
                  () =>
                      actions.planOnDate(item, picked.date, time: picked.time),
                );
              }
            }),
            _choice(
              Icons.person_outline,
              context.l10n.reviewWaitingOnChoice,
              () async {
                final person = await _askPerson();
                if (person != null) {
                  await decide(_planned, () => actions.waitFor(item, person));
                }
              },
            ),
            _choice(Icons.lightbulb_outline, context.l10n.someday, () async {
              await decide(_cleared, () => actions.moveToSomeday(item));
              await _tally(_parked);
            }),
            _choice(
              Icons.check,
              context.l10n.reviewAlreadyDone,
              () => decide(_cleared, () => actions.complete(item)),
            ),
            _choice(
              Icons.delete_outline,
              context.l10n.commonDelete,
              () => decide(_cleared, () => actions.trash(item)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _choice(IconData icon, String label, VoidCallback onPressed) =>
      ActionChip(
        avatar: Icon(icon, size: 18),
        label: Text(label),
        onPressed: onPressed,
      );

  Future<String?> _askPerson() async {
    final controller = TextEditingController();
    final person = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.reviewWhoWaitingOn),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(hintText: context.l10n.commonName),
          onSubmitted: (value) => Navigator.pop(context, value),
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
    return person == null || person.trim().isEmpty ? null : person.trim();
  }

  /// An item with a done button and a few review actions.
  Widget _row(Item item, List<Widget> actions, {String? subtitle}) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: IconButton(
      icon: const Icon(Icons.radio_button_unchecked),
      tooltip: context.l10n.reviewMarkDone,
      onPressed: () async {
        await ref.read(itemActionsProvider).complete(item);
        await _tally(_cleared);
      },
    ),
    title: Text(item.title),
    subtitle: subtitle == null ? null : Text(subtitle),
    trailing: Row(mainAxisSize: MainAxisSize.min, children: actions),
  );

  Widget _replan(Item item) => IconButton(
    icon: const Icon(Icons.event_outlined),
    tooltip: context.l10n.reviewReplan,
    onPressed: () async {
      final choice = await showWhenSheet(context, today: _today);
      if (choice == null) return;
      await ref.plan(item, choice);
      await _tally(_planned);
    },
  );

  Widget _letGo(Item item) => IconButton(
    icon: const Icon(Icons.lightbulb_outline),
    tooltip: context.l10n.reviewLetGo,
    onPressed: () async {
      await ref.read(itemActionsProvider).moveToSomeday(item);
      await _tally(_cleared);
      await _tally(_parked);
    },
  );

  Widget _lastWeek() {
    final items = lastWeekOpen(_openItems, _today);
    return FlowStep(
      question: context.l10n.reviewLastWeekTitle,
      hint: items.isEmpty
          ? context.l10n.reviewLastWeekEmpty
          : context.l10n.reviewLastWeekHint,
      actions: [_nextButton()],
      children: [
        for (final item in items) _row(item, [_replan(item), _letGo(item)]),
      ],
    );
  }

  Widget _waiting() {
    final today = _today;
    final actions = ref.read(itemActionsProvider);
    final items = [
      for (final item in _openItems)
        if (item.status == ItemStatus.waiting) item,
    ];
    return FlowStep(
      question: context.l10n.waitingOn,
      hint: items.isEmpty
          ? context.l10n.reviewWaitingEmpty
          : context.l10n.reviewWaitingHint,
      actions: [_nextButton()],
      children: [
        for (final item in items)
          _row(
            item,
            subtitle: [
              item.waitingOn ?? context.l10n.reviewSomeone,
              if (item.followUpDate case final date?)
                context.l10n.reviewFollowUpOn(dateLabel(date, today)),
            ].join(' · '),
            [
              IconButton(
                icon: const Icon(Icons.event_repeat_outlined),
                tooltip: context.l10n.reviewFollowUpTooltip,
                onPressed: () async {
                  final picked = await pickDate(
                    context,
                    today: today,
                    askTime: false,
                  );
                  if (picked == null) return;
                  await actions.save(
                    item.copyWith(followUpDate: () => picked.date),
                  );
                  await _tally(_planned);
                },
              ),
              IconButton(
                icon: const Icon(Icons.undo),
                tooltip: context.l10n.reviewTakeBack,
                onPressed: () async {
                  await actions.planToday(item);
                  await _tally(_planned);
                },
              ),
            ],
          ),
      ],
    );
  }

  Widget _nextWeek() {
    final today = _today;
    final items = nextSevenDays(_openItems, today);
    final open = _openItems;
    final stuck = [
      for (final list in ref.watch(listsProvider).value ?? const <ItemList>[])
        if (list.isProject &&
            !list.archived &&
            !open.any(
              (i) => i.listId == list.id && i.status == ItemStatus.active,
            ))
          list,
    ];
    return FlowStep(
      question: context.l10n.reviewNextWeekTitle,
      hint: items.isEmpty
          ? context.l10n.reviewNextWeekEmpty
          : context.l10n.reviewNextWeekHint,
      actions: [_nextButton()],
      children: [
        for (final item in items)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(item.title),
            subtitle: Text(
              [
                dateLabel(item.doDate!, today),
                if (item.doTime case final t?) timeLabel(context, t),
              ].join(', '),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.item(item.id)),
          ),
        if (stuck.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            context.l10n.reviewProjectsStuck(stuck.length),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          for (final project in stuck)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.flag_outlined),
              title: Text(project.name),
              subtitle: project.outcome == null ? null : Text(project.outcome!),
              trailing: Wrap(
                children: [
                  TextButton(
                    onPressed: () => ref
                        .read(listRepositoryProvider)
                        .save(project.copyWith(archived: true)),
                    child: Text(context.l10n.reviewProjectPark),
                  ),
                  TextButton(
                    onPressed: () =>
                        showCaptureSheet(context, listId: project.id),
                    child: Text(context.l10n.reviewProjectAddStep),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }

  Widget _someday() {
    final items = [
      for (final item in _openItems)
        if (item.status == ItemStatus.someday) item,
    ];
    return FlowStep(
      question: context.l10n.someday,
      hint: items.isEmpty
          ? context.l10n.reviewSomedayEmpty
          : context.l10n.reviewSomedayHint,
      actions: [
        if (items.isNotEmpty)
          TextButton(onPressed: _next, child: Text(context.l10n.commonSkip)),
        _nextButton(),
      ],
      children: [
        for (final item in items)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(item.title),
            trailing: IconButton(
              icon: const Icon(Icons.arrow_upward),
              tooltip: context.l10n.reviewMakePlan,
              onPressed: () async {
                final choice = await showWhenSheet(
                  context,
                  today: _today,
                  title: context.l10n.reviewWhenWillYou,
                );
                if (choice == null) return;
                await ref.plan(item, choice);
                await _tally(_planned);
              },
            ),
          ),
      ],
    );
  }

  Widget _close(ReviewSession session) {
    final theme = Theme.of(context);
    final skipped = session.count(_skipped);
    return FlowStep(
      question: context.l10n.reviewCloseTitle,
      hint: context.l10n.reviewCloseHint,
      actions: [
        FilledButton(
          onPressed: _finish,
          child: Text(context.l10n.commonFinish),
        ),
      ],
      children: [
        const Center(child: ClearingArt(ClearingScene.clearing)),
        const SizedBox(height: 24),
        // A summary on open space: no score, streak or comparison.
        Text(
          context.l10n.reviewCloseSummary(
            session.count(_cleared),
            session.count(_planned),
          ),
          style: theme.textTheme.displaySmall,
          textAlign: TextAlign.center,
        ),
        if (skipped > 0) ...[
          const SizedBox(height: 8),
          Text(
            context.l10n.reviewCloseSkipped(skipped),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 24),
        LookBack(parked: session.count(_parked)),
        if (ref.watch(settingsProvider).value?.winsPrompt ?? true) ...[
          const SizedBox(height: 24),
          TextField(
            controller: _wins,
            maxLines: null,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: context.l10n.lookBackWins,
              helperText: context.l10n.lookBackWinsHint,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ],
    );
  }
}
