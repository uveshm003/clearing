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
