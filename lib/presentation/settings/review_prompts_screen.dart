import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../l10n/l10n.dart';

/// Your own weekly review checks (§4.10): "Check the bank account",
/// "Plan meals". They're added as one step before the review's close.
class ReviewPromptsScreen extends ConsumerStatefulWidget {
  const ReviewPromptsScreen({super.key});

  @override
  ConsumerState<ReviewPromptsScreen> createState() =>
      _ReviewPromptsScreenState();
}

class _ReviewPromptsScreenState extends ConsumerState<ReviewPromptsScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save(List<String> prompts) async {
    final repository = ref.read(settingsRepositoryProvider);
    final settings = await repository.get();
    await repository.save(settings.copyWith(reviewPrompts: prompts));
  }

  @override
  Widget build(BuildContext context) {
    final prompts =
        ref.watch(settingsProvider).value?.reviewPrompts ?? const <String>[];
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsReviewPrompts)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 8, 8),
            child: TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.reviewPromptAdd,
                hintText: l10n.settingsReviewPromptsHint,
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: l10n.reviewPromptAdd,
                  onPressed: () => _add(prompts),
                ),
              ),
              onSubmitted: (_) => _add(prompts),
            ),
          ),
          for (final (i, prompt) in prompts.indexed)
            ListTile(
              leading: const Icon(Icons.check_box_outline_blank),
              title: Text(prompt),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                tooltip: l10n.commonRemove,
                onPressed: () => _save([...prompts]..removeAt(i)),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _add(List<String> prompts) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    await _save([...prompts, text]);
  }
}
