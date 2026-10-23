import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../l10n/l10n.dart';

/// One screen of a guided flow (weekly review, overwhelm reset): a question,
/// optional hint, content, and actions pinned to the bottom so they never
/// scroll out of reach.
class FlowStep extends StatelessWidget {
  const FlowStep({
    super.key,
    required this.question,
    this.hint,
    required this.children,
    required this.actions,
  });

  final String question;
  final String? hint;
  final List<Widget> children;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            children: [
              Semantics(
                header: true,
                child: Text(question, style: theme.textTheme.headlineSmall),
              ),
              if (hint case final hint?) ...[
                const SizedBox(height: 8),
                Text(
                  hint,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              ...children,
            ],
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: actions,
          ),
        ),
      ],
    );
  }
}

/// Burst capture inside a flow: Enter saves to the Inbox and keeps the
/// field ready for the next thought (FR-01). [onSaved] gets the count.
class BurstCapture extends ConsumerStatefulWidget {
  const BurstCapture({super.key, this.onSaved});

  final ValueChanged<int>? onSaved;

  @override
  ConsumerState<BurstCapture> createState() => _BurstCaptureState();
}

class _BurstCaptureState extends ConsumerState<BurstCapture> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  final _saved = <String>[];

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final items = await ref.read(itemActionsProvider).capture(_controller.text);
    if (items.isEmpty || !mounted) return;
    _controller.clear();
    _focus.requestFocus();
    setState(() => _saved.insertAll(0, items.map((i) => i.title)));
    widget.onSaved?.call(items.length);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focus,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: context.l10n.flowCaptureHint,
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.arrow_upward),
              tooltip: context.l10n.commonSave,
              onPressed: _save,
            ),
          ),
          onSubmitted: (_) => _save(),
        ),
        if (_saved.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              context.l10n.flowSavedToInbox(_saved.length, _saved.first),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}
