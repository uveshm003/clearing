import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/router.dart';
import '../../domain/enums.dart';
import '../../domain/item.dart';
import '../../domain/local_date.dart';
import '../../domain/review_rules.dart';
import '../../domain/review_session.dart';
import '../format.dart';
import '../item_commands.dart';
import '../widgets/flow_step.dart';
import '../widgets/when_sheet.dart';

/// Tally keys saved with the session. A summary, never a score.
const _cleared = 'cleared';
const _planned = 'planned';
const _skipped = 'skipped';

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

  ReviewStep get _step =>
      ReviewStep.values[(_session?.step ?? 0).clamp(
        0,
        ReviewStep.values.length - 1,
      )];

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

  Future<void> _next() => _go(ReviewStep.values[_step.index + 1]);

  Future<void> _finish() async {
    if (_session case final session?) {
      await _save(session.copyWith(completedAt: ref.read(clockProvider)()));
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    final step = _step;
    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        title: Text(
          'Weekly review · ${step.index + 1} of ${ReviewStep.values.length}',
        ),
      ),
      body: session == null
          ? const SizedBox.shrink()
          : SafeArea(
              child: Column(
                children: [
                  if (_resumed)
                    MaterialBanner(
                      content: const Text('Picking up where you left off.'),
                      actions: [
                        TextButton(
                          onPressed: () => _go(ReviewStep.emptyHead),
                          child: const Text('Start over'),
                        ),
                      ],
                    ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: KeyedSubtree(
                        key: ValueKey(step),
                        child: switch (step) {
                          ReviewStep.emptyHead => _emptyHead(),
                          ReviewStep.inbox => _inbox(),
                          ReviewStep.lastWeek => _lastWeek(),
                          ReviewStep.waiting => _waiting(),
                          ReviewStep.nextWeek => _nextWeek(),
                          ReviewStep.someday => _someday(),
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

  Widget _nextButton([String label = 'Next']) =>
      FilledButton(onPressed: _next, child: Text(label));

  List<Item> get _openItems => ref.watch(openItemsProvider).value ?? const [];

  Widget _emptyHead() => FlowStep(
    question: 'Empty your head',
    hint:
        'Anything not written down yet: errands, worries, replies you owe. '
        'One thought at a time.',
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
        question: 'Inbox clear',
        hint: _skippedIds.isEmpty
            ? 'Every item has a place.'
            : '${_skippedIds.length} skipped for now. They’ll be here next '
                  'time.',
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
      hint: '${inbox.length} left in the inbox. Where does this one go?',
      actions: [
        TextButton(
          onPressed: () async {
            setState(() => _skippedIds.add(item.id));
            await _tally(_skipped);
          },
          child: const Text('Skip for now'),
        ),
      ],
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _choice(
              Icons.wb_sunny_outlined,
              'Today',
              () => decide(_planned, () => actions.planToday(item)),
            ),
            _choice(
              Icons.view_week_outlined,
              'This week',
              () => decide(_planned, () => actions.planThisWeek(item)),
            ),
            _choice(Icons.event_outlined, 'Pick a date', () async {
              final picked = await pickDate(context, today: today);
              if (picked != null) {
                await decide(
                  _planned,
                  () =>
                      actions.planOnDate(item, picked.date, time: picked.time),
                );
              }
            }),
            _choice(Icons.person_outline, 'Waiting on…', () async {
              final person = await _askPerson();
              if (person != null) {
                await decide(_planned, () => actions.waitFor(item, person));
              }
            }),
            _choice(
              Icons.lightbulb_outline,
              'Someday',
              () => decide(_cleared, () => actions.moveToSomeday(item)),
            ),
            _choice(
              Icons.check,
              'Already done',
              () => decide(_cleared, () => actions.complete(item)),
            ),
            _choice(
              Icons.delete_outline,
              'Delete',
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
        title: const Text('Who are you waiting on?'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Name'),
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
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
      tooltip: 'Mark done',
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
    tooltip: 'Re-plan',
    onPressed: () async {
      final choice = await showWhenSheet(context, today: _today);
      if (choice == null) return;
      await ref.plan(item, choice);
      await _tally(_planned);
    },
  );

  Widget _letGo(Item item) => IconButton(
    icon: const Icon(Icons.lightbulb_outline),
    tooltip: 'Let go to Someday',
    onPressed: () async {
      await ref.read(itemActionsProvider).moveToSomeday(item);
      await _tally(_cleared);
    },
  );

  Widget _lastWeek() {
    final items = lastWeekOpen(_openItems, _today);
    return FlowStep(
      question: 'Last week’s open items',
      hint: items.isEmpty
          ? 'Nothing left over from last week.'
          : 'This week’s items and anything carried over. Re-plan them, or '
                'let them go.',
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
      question: 'Waiting on',
      hint: items.isEmpty
          ? 'You’re not waiting on anyone.'
          : 'Follow up, mark done, or take it back to do yourself.',
      actions: [_nextButton()],
      children: [
        for (final item in items)
          _row(
            item,
            subtitle: [
              item.waitingOn ?? 'Someone',
              if (item.followUpDate case final date?)
                'follow up ${dateLabel(date, today)}',
            ].join(' · '),
            [
              IconButton(
                icon: const Icon(Icons.event_repeat_outlined),
                tooltip: 'Follow up on…',
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
                tooltip: 'Take it back',
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
    return FlowStep(
      question: 'The next 7 days',
      hint: items.isEmpty
          ? 'Nothing dated this coming week.'
          : 'A glance at what’s coming. Tap one to adjust it.',
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
      ],
    );
  }

  Widget _someday() {
    final items = [
      for (final item in _openItems)
        if (item.status == ItemStatus.someday) item,
    ];
    return FlowStep(
      question: 'Someday',
      hint: items.isEmpty
          ? 'No ideas parked.'
          : 'Optional. Anything here ready to become a plan?',
      actions: [
        if (items.isNotEmpty)
          TextButton(onPressed: _next, child: const Text('Skip')),
        _nextButton(),
      ],
      children: [
        for (final item in items)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(item.title),
            trailing: IconButton(
              icon: const Icon(Icons.arrow_upward),
              tooltip: 'Make it a plan',
              onPressed: () async {
                final choice = await showWhenSheet(
                  context,
                  today: _today,
                  title: 'When will you do it?',
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
      question: 'That’s the week',
      hint: 'Your head should feel a little lighter.',
      actions: [FilledButton(onPressed: _finish, child: const Text('Finish'))],
      children: [
        Text(
          '${session.count(_cleared)} cleared · '
          '${session.count(_planned)} planned',
          style: theme.textTheme.titleLarge,
        ),
        if (skipped > 0) ...[
          const SizedBox(height: 8),
          Text('$skipped skipped for another time.'),
        ],
      ],
    );
  }
}
