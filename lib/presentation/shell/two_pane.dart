import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router.dart';

/// From this width (tablets, unfolded foldables) the app shows two panes:
/// the list, and the item beside it.
const twoPaneWidth = 840.0;

bool isTwoPane(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= twoPaneWidth;

/// The item open in the side pane, if any.
class SelectedItem extends Notifier<String?> {
  @override
  String? build() => null;

  void open(String id) => state = id;

  void close() => state = null;
}

final selectedItemProvider = NotifierProvider<SelectedItem, String?>(
  SelectedItem.new,
);

/// Marks the part of the tree inside the four-tab shell, where a side pane
/// can show an item. Screens pushed over the shell (search, flows) open
/// items as pages instead.
class ShellScope extends InheritedWidget {
  const ShellScope({super.key, required super.child});

  static bool contains(BuildContext context) =>
      context.getInheritedWidgetOfExactType<ShellScope>() != null;

  @override
  bool updateShouldNotify(ShellScope old) => false;
}

/// Opens an item: beside the list on wide screens, as a page elsewhere.
void openItem(BuildContext context, WidgetRef ref, String id) {
  if (isTwoPane(context) && ShellScope.contains(context)) {
    ref.read(selectedItemProvider.notifier).open(id);
  } else {
    context.push(Routes.item(id));
  }
}
