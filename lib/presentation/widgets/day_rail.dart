import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/glade.dart';
import '../../domain/local_date.dart';
import '../format.dart';

/// One day of the agenda or week view in Glade: a date marker on the left
/// rail (weekday over a serif day number, today ringed in dawn) and the
/// day's items on a pebble beside it.
class DaySection extends StatelessWidget {
  const DaySection({
    super.key,
    required this.day,
    required this.today,
    required this.children,
    this.emptyText,
  });

  final LocalDate day;
  final LocalDate today;
  final List<Widget> children;

  /// Shown in the pebble when [children] is empty ("Free").
  final String? emptyText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final glade = GladeTokens.of(context);
    final isToday = day == today;
    final date = dateTimeOf(day);
    return Semantics(
      container: true,
      label: dateLabel(day, today),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          GladeSpace.lg,
          GladeSpace.sm,
          GladeSpace.lg,
          GladeSpace.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: SizedBox(
                width: 56,
                child: Column(
                  children: [
                    const SizedBox(height: GladeSpace.sm),
                    Text(
                      DateFormat.E().format(date),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: isToday
                          ? BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: glade.dawn, width: 2.5),
                            )
                          : null,
                      child: Text(
                        '${day.day}',
                        style: theme.textTheme.headlineSmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: GladeSpace.sm),
            Expanded(
              child: Material(
                color: scheme.surfaceContainer,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(GladeSpace.pebble),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: GladeSpace.xs),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (children.isEmpty && emptyText != null)
                        Padding(
                          padding: const EdgeInsets.all(GladeSpace.lg),
                          child: Text(
                            emptyText!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ...children,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
