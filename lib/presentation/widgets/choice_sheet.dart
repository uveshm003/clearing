import 'package:flutter/material.dart';

/// Asks the user to pick one of [options] in a bottom sheet. Unlike a
/// dropdown it never runs out of room, at any text size (FR-20).
///
/// Returns the picked value wrapped in a record, so picking a null option
/// ("None") can be told apart from cancelling (null).
Future<({T value})?> showChoiceSheet<T>(
  BuildContext context, {
  required String title,
  required List<(T, String)> options,
  required T selected,
}) => showModalBottomSheet<({T value})>(
  context: context,
  builder: (context) => SafeArea(
    child: SingleChildScrollView(
      child: RadioGroup<T>(
        groupValue: selected,
        onChanged: (value) => Navigator.pop(context, (value: value as T)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final (value, label) in options)
              RadioListTile<T>(value: value, title: Text(label)),
          ],
        ),
      ),
    ),
  ),
);

/// A settings row showing the current choice; tapping opens
/// [showChoiceSheet]. Replaces a trailing dropdown, which runs out of room
/// at large text sizes (FR-20).
class ChoiceTile<T> extends StatelessWidget {
  const ChoiceTile({
    super.key,
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
    this.hint,
    this.enabled = true,
  });

  final String title;
  final T value;
  final List<(T, String)> options;
  final ValueChanged<T> onChanged;

  /// A line under the current choice explaining the setting.
  final String? hint;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final current =
        options.where((o) => o.$1 == value).firstOrNull?.$2 ?? '$value';
    return ListTile(
      enabled: enabled,
      title: Text(title),
      subtitle: Text([current, ?hint].join(' · ')),
      trailing: const Icon(Icons.unfold_more),
      onTap: () async {
        final picked = await showChoiceSheet<T>(
          context,
          title: title,
          options: options,
          selected: value,
        );
        if (picked != null) onChanged(picked.value);
      },
    );
  }
}
