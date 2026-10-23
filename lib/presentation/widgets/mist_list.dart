import 'package:flutter/material.dart';

import '../../core/glade.dart';

/// A lazily built list that animates its rows in and out by key (Glade's
/// "Mist"): a row leaving lifts a little and fades while the gap closes; a
/// new row settles in. With animations switched off, changes are instant.
///
/// Only rows on screen are built, so long lists stay smooth.
class SliverMistList<T> extends StatefulWidget {
  const SliverMistList({
    super.key,
    required this.items,
    required this.keyOf,
    required this.itemBuilder,
  });

  final List<T> items;
  final String Function(T item) keyOf;

  /// Builds a row. [leaving] is true while a removed row animates away.
  final Widget Function(BuildContext context, T item, {bool leaving})
  itemBuilder;

  @override
  State<SliverMistList<T>> createState() => _SliverMistListState<T>();
}

class _SliverMistListState<T> extends State<SliverMistList<T>> {
  final _list = GlobalKey<SliverAnimatedListState>();
  late List<T> _shown = [...widget.items];

  @override
  void didUpdateWidget(SliverMistList<T> old) {
    super.didUpdateWidget(old);
    final next = widget.items;
    final nextKeys = {for (final item in next) widget.keyOf(item)};
    final state = _list.currentState;
    if (state == null) {
      _shown = [...next];
      return;
    }

    // Removals first, from the end, so indices stay valid.
    for (var i = _shown.length - 1; i >= 0; i--) {
      final item = _shown[i];
      if (nextKeys.contains(widget.keyOf(item))) continue;
      _shown.removeAt(i);
      state.removeItem(
        i,
        (context, animation) => _leaving(context, item, animation),
        duration: GladeMotion.mist.of(context),
      );
    }

    // What stays keeps its place in the new order; new rows settle in.
    final kept = {for (final item in _shown) widget.keyOf(item)};
    _shown = [...next];
    for (var i = 0; i < next.length; i++) {
      if (!kept.contains(widget.keyOf(next[i]))) {
        state.insertItem(i, duration: GladeMotion.settle.of(context));
      }
    }
  }

  Widget _leaving(BuildContext context, T item, Animation<double> animation) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: GladeMotion.mist.curve,
    );
    return SizeTransition(
      sizeFactor: curved,
      child: FadeTransition(
        opacity: curved,
        child: SlideTransition(
          // Lifts about 8 dp as it fades.
          position: Tween(
            begin: const Offset(0, -0.15),
            end: Offset.zero,
          ).animate(curved),
          child: IgnorePointer(
            child: widget.itemBuilder(context, item, leaving: true),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => SliverAnimatedList(
    key: _list,
    initialItemCount: _shown.length,
    itemBuilder: (context, index, animation) {
      final item = _shown[index];
      final curved = CurvedAnimation(
        parent: animation,
        curve: GladeMotion.settle.curve,
      );
      return SizeTransition(
        key: ValueKey(widget.keyOf(item)),
        sizeFactor: curved,
        child: FadeTransition(
          opacity: curved,
          child: widget.itemBuilder(context, item),
        ),
      );
    },
  );
}
