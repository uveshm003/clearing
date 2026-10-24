import 'package:flutter/material.dart';

import '../../domain/item.dart';
import '../../domain/repeat_series.dart';
import '../../domain/local_date.dart';
import '../format.dart';

/// The fields people change most, as chips at the top of an item (§4.6):
/// each opens its editor straight away, without scrolling to it.
class ItemSummaryChips extends StatelessWidget {
  const ItemSummaryChips({
    super.key,
    required this.item,
    required this.when,
    required this.today,
    required this.onWhen,
    required this.onList,
    this.listName,
    this.series,
    this.onRepeat,
    this.onEffort,
  });

  final Item item;

  /// "Today", "Fri 23 Oct, 09:00"…
  final String when;
  final LocalDate today;
  final String? listName;
  final RepeatSeries? series;
  final VoidCallback onWhen;
  final VoidCallback onList;
  final VoidCallback? onRepeat;
  final VoidCallback? onEffort;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          ActionChip(
            avatar: const Icon(Icons.event_outlined, size: 18),
            label: Text(when),
            onPressed: onWhen,
          ),
          if (listName case final name?)
            ActionChip(
              avatar: const Icon(Icons.list_alt_outlined, size: 18),
              label: Text(name),
              onPressed: onList,
            ),
          if (series case final series? when onRepeat != null)
            ActionChip(
              avatar: const Icon(Icons.repeat, size: 18),
              label: Text(describeRepeat(series, today)),
              onPressed: onRepeat,
            ),
          if (item.effort case final effort? when onEffort != null)
            ActionChip(
              avatar: const Icon(Icons.timelapse, size: 18),
              label: Text(effortLabel(effort)),
              onPressed: onEffort,
            ),
        ],
      ),
    );
  }
}
