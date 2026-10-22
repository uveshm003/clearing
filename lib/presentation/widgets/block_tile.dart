import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/router.dart';
import '../../domain/batch_block.dart';
import '../../domain/enums.dart';
import '../format.dart';

/// A batch block as one entry, e.g. "Errands · 10:00 · 4 to do" (FR-05).
/// Tapping opens the list to work through.
class BlockTile extends ConsumerWidget {
  const BlockTile({super.key, required this.block});

  final BatchBlock block;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref
        .watch(listsProvider)
        .value
        ?.where((l) => l.id == block.listId)
        .firstOrNull;
    final toDo = (ref.watch(openItemsProvider).value ?? const [])
        .where((i) => i.listId == block.listId && i.status == ItemStatus.active)
        .length;
    if (list == null) return const SizedBox.shrink();
    return ListTile(
      leading: const Icon(Icons.event_available_outlined),
      title: Text('${list.name} · ${timeLabel(context, block.time)}'),
      subtitle: Text(toDo == 0 ? 'All done' : '$toDo to do, in one go'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(Routes.list(block.listId)),
    );
  }
}

/// Asks when to block out time for a list: once, or every week.
Future<({LocalDateChoice when, int time})?> pickBlockTime(
  BuildContext context, {
  required DateTime now,
  int weekStart = DateTime.monday,
}) => showDialog(
  context: context,
  builder: (context) => _BlockDialog(now: now, weekStart: weekStart),
);

/// Once on [date], or weekly on [weekday].
typedef LocalDateChoice = ({DateTime? date, int? weekday});

class _BlockDialog extends StatefulWidget {
  const _BlockDialog({required this.now, required this.weekStart});

  final DateTime now;
  final int weekStart;

  @override
  State<_BlockDialog> createState() => _BlockDialogState();
}

class _BlockDialogState extends State<_BlockDialog> {
  var _weekly = true;
  late var _weekday = DateTime.saturday;
  late var _date = DateTime(widget.now.year, widget.now.month, widget.now.day);
  var _time = 10 * 60;

  @override
  Widget build(BuildContext context) {
    final days = [
      for (var i = 0; i < 7; i++) (widget.weekStart - 1 + i) % 7 + 1,
    ];
    return AlertDialog(
      title: const Text('Block out time'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Work through the whole list in one go.'),
          const SizedBox(height: 16),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('Every week')),
              ButtonSegment(value: false, label: Text('Once')),
            ],
            selected: {_weekly},
            onSelectionChanged: (s) => setState(() => _weekly = s.single),
          ),
          const SizedBox(height: 8),
          if (_weekly)
            DropdownButton<int>(
              value: _weekday,
              isExpanded: true,
              items: [
                for (final day in days)
                  DropdownMenuItem(value: day, child: Text(weekdayLong(day))),
              ],
              onChanged: (day) => setState(() => _weekday = day!),
            )
          else
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                MaterialLocalizations.of(context).formatMediumDate(_date),
              ),
              trailing: const Icon(Icons.edit_calendar_outlined),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(
                    widget.now.year,
                    widget.now.month,
                    widget.now.day,
                  ),
                  lastDate: widget.now.add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('At ${timeLabel(context, _time)}'),
            trailing: const Icon(Icons.schedule),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: timeOfDay(_time),
              );
              if (picked != null) setState(() => _time = minutesOf(picked));
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, (
            when: (
              date: _weekly ? null : _date,
              weekday: _weekly ? _weekday : null,
            ),
            time: _time,
          )),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
