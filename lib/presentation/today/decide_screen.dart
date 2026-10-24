import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/item.dart';
import '../../l10n/l10n.dart';
import '../item_commands.dart';
import '../widgets/clearing_art.dart';
import '../widgets/flow_step.dart';
import '../widgets/when_sheet.dart';

/// "Decide these" (§4.2): one carried-over item at a time — Today, This
/// week, Someday, or let it go. A calm way out of a pile that grew quietly.
class DecideScreen extends ConsumerStatefulWidget {
  const DecideScreen({super.key});

  @override
  ConsumerState<DecideScreen> createState() => _DecideScreenState();
}

class _DecideScreenState extends ConsumerState<DecideScreen> {
  /// Fixed when the screen opens, so deciding one doesn't reshuffle the rest.
  List<Item>? _queue;
  var _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    _queue ??= ref.watch(todayViewProvider).value?.carriedOver;
    final queue = _queue;
    final done = queue == null || _index >= queue.length;

    Future<void> decide(Future<Object?> Function(Item item) change) async {
      await change(queue![_index]);
      setState(() => _index++);
    }

    final actions = ref.read(itemActionsProvider);
    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        title: Text(l10n.decideTitle),
      ),
      body: SafeArea(
        child: done
            ? FlowStep(
                question: l10n.decideDoneTitle,
                hint: l10n.decideDoneBody,
                actions: [
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.commonDone),
                  ),
                ],
                children: const [
                  Center(child: ClearingArt(ClearingScene.clearing)),
                ],
              )
            : FlowStep(
                question: queue[_index].title,
                hint: l10n.decideHint(queue.length - _index),
                actions: [
                  TextButton(
                    onPressed: () => decide(actions.trash),
                    child: Text(l10n.decideLetGo),
                  ),
                  TextButton(
                    onPressed: () => decide(actions.moveToSomeday),
                    child: Text(l10n.someday),
                  ),
                  OutlinedButton(
                    onPressed: () =>
                        decide((item) => ref.plan(item, const WhenThisWeek())),
                    child: Text(l10n.whenThisWeek),
                  ),
                  FilledButton(
                    onPressed: () =>
                        decide((item) => ref.plan(item, const WhenToday())),
                    child: Text(l10n.whenToday),
                  ),
                ],
                children: const [],
              ),
      ),
    );
  }
}
