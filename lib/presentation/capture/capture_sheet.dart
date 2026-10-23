import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/glade.dart';
import '../../core/providers.dart';
import '../../domain/enums.dart';
import '../../domain/starter_suggestion.dart';
import '../../l10n/l10n.dart';

/// Opens quick capture (FR-01). [listId] files captures under a list, e.g.
/// when opened from that list's screen.
Future<void> showCaptureSheet(
  BuildContext context, {
  String? initialText,
  String? listId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => CaptureSheet(initialText: initialText, listId: listId),
  );
}

class CaptureSheet extends ConsumerStatefulWidget {
  const CaptureSheet({super.key, this.initialText, this.listId});

  final String? initialText;
  final String? listId;

  @override
  ConsumerState<CaptureSheet> createState() => _CaptureSheetState();
}

class _CaptureSheetState extends ConsumerState<CaptureSheet> {
  late final _controller = TextEditingController.fromValue(
    TextEditingValue(
      text: widget.initialText ?? '',
      selection: TextSelection.collapsed(
        offset: widget.initialText?.length ?? 0,
      ),
    ),
  );

  /// Enter saves, as on the keyboard's action button; Shift+Enter still
  /// starts a new line. Needed because a multi-line field would otherwise
  /// insert a newline for a hardware Enter.
  late final _focus = FocusNode(
    onKeyEvent: (node, event) {
      if (event is KeyDownEvent &&
          event.logicalKey == LogicalKeyboardKey.enter &&
          !HardwareKeyboard.instance.isShiftPressed) {
        _save();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    },
  );
  final _saved = <String>[];

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  /// Saves and clears the field but keeps it open for the next thought.
  Future<void> _save([String? text]) async {
    final value = text ?? _controller.text;
    if (value.trim().isEmpty) return;
    final items = await ref
        .read(itemActionsProvider)
        .capture(value, listId: widget.listId);
    if (!mounted) return;
    setState(() => _saved.insertAll(0, items.reversed.map((i) => i.title)));
    if (text == null) _controller.clear();
    _focus.requestFocus();
    SemanticsService.sendAnnouncement(
      View.of(context),
      context.l10n.captureSavedAnnouncement(items.length),
      Directionality.of(context),
    );
  }

  Future<void> _saveSuggestion(StarterSuggestion suggestion) async {
    final kind = suggestion.listKind;
    final listId =
        widget.listId ??
        ref
            .read(listsProvider)
            .value
            ?.where((l) => kind != null && l.kind == kind)
            .firstOrNull
            ?.id;
    final items = await ref
        .read(itemActionsProvider)
        .capture(suggestion.title, listId: listId);
    if (!mounted) return;
    setState(() => _saved.insertAll(0, items.reversed.map((i) => i.title)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider).value;
    final suggestions = (settings?.starterSuggestions ?? false)
        ? (ref.watch(suggestionsProvider).value ?? const [])
              .where((s) => s.enabled)
              .toList()
        : const <StarterSuggestion>[];
    final listName = widget.listId == null
        ? null
        : ref
              .watch(listsProvider)
              .value
              ?.where((l) => l.id == widget.listId)
              .firstOrNull
              ?.name;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_saved.isNotEmpty) _SavedStack(saved: _saved),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 8, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focus,
                    autofocus: true,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.done,
                    style: theme.textTheme.titleMedium,
                    decoration: InputDecoration(
                      hintText: context.l10n.captureHint,
                      helperText: listName == null
                          ? context.l10n.captureHelper
                          : context.l10n.captureHelperInList(listName),
                    ),
                    onSubmitted: (_) => _save(),
                  ),
                ),
                IconButton.filledTonal(
                  icon: const Icon(Icons.arrow_upward),
                  tooltip: context.l10n.commonSave,
                  onPressed: _save,
                ),
              ],
            ),
          ),
          if (suggestions.isNotEmpty)
            // Tall enough for each chip's full 48 dp touch target (FR-20).
            SizedBox(
              height: 64,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                children: [
                  for (final s in suggestions)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        avatar: Icon(_iconFor(s.listKind), size: 18),
                        label: Text(s.title),
                        onPressed: () => _saveSuggestion(s),
                      ),
                    ),
                ],
              ),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: TextButton(
                onPressed: () async {
                  await _save();
                  if (context.mounted) Navigator.pop(context);
                },
                child: Text(context.l10n.commonDone),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static IconData _iconFor(ListKind? kind) => switch (kind) {
    ListKind.lifeAdmin => Icons.receipt_long_outlined,
    ListKind.errands => Icons.shopping_bag_outlined,
    _ => Icons.add,
  };
}

/// Glade's "Emptying your head": each thought saved in burst mode slides up
/// into a small stack above the field, newest in front, the older ones
/// fading back, with a count.
class _SavedStack extends StatelessWidget {
  const _SavedStack({required this.saved});

  /// Newest first.
  final List<String> saved;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shown = saved.take(3).toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            liveRegion: true,
            child: Text(
              context.l10n.captureSavedCount(saved.length),
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 6),
          for (final (i, title) in shown.indexed.toList().reversed)
            AnimatedSwitcher(
              duration: GladeMotion.settle.of(context),
              transitionBuilder: (child, animation) => SlideTransition(
                position: Tween(
                  begin: const Offset(0, 0.6),
                  end: Offset.zero,
                ).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: Opacity(
                key: ValueKey('${saved.length - i}:$title'),
                opacity: const [1.0, 0.7, 0.45][i],
                child: Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHigh,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(GladeSpace.md),
                    ),
                  ),
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
