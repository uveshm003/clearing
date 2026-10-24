import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/providers.dart';
import '../../domain/item.dart';
import '../../domain/links.dart';
import '../../l10n/l10n.dart';
import '../format.dart';
import '../widgets/choice_sheet.dart';

/// How long an item takes and where it can be done (FR-22), each one tap.
class EffortAndContexts extends ConsumerWidget {
  const EffortAndContexts({super.key, required this.item});

  final Item item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final contexts = ref.watch(contextsProvider).value ?? const [];
    final mine = ref.watch(itemContextsProvider).value?[item.id] ?? const {};
    final names = [
      for (final c in contexts)
        if (mine.contains(c.id)) contextLabel(c),
    ];
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.timelapse),
          title: Text(l10n.itemEffort),
          subtitle: Text(
            item.effort == null
                ? l10n.itemEffortNone
                : effortLabel(item.effort!),
          ),
          onTap: () => pickEffort(context, ref, item),
        ),
        ListTile(
          leading: const Icon(Icons.place_outlined),
          title: Text(l10n.itemContexts),
          subtitle: Text(
            names.isEmpty ? l10n.itemContextsNone : names.join(', '),
          ),
          onTap: () async {
            final picked = await showModalBottomSheet<Set<String>>(
              context: context,
              builder: (context) => _ContextPicker(
                selected: mine,
                options: [for (final c in contexts) (c.id, contextLabel(c))],
              ),
            );
            if (picked != null) {
              await ref
                  .read(contextRepositoryProvider)
                  .setForItem(item.id, picked);
            }
          },
        ),
      ],
    );
  }
}

/// Picks an item's effort from [Item.effortSteps].
Future<void> pickEffort(BuildContext context, WidgetRef ref, Item item) async {
  final picked = await showChoiceSheet<int?>(
    context,
    title: context.l10n.effortTitle,
    selected: item.effort,
    options: [
      (null, context.l10n.itemEffortNone),
      for (final minutes in Item.effortSteps) (minutes, effortLabel(minutes)),
    ],
  );
  if (picked != null) {
    await ref.read(itemActionsProvider).setEffort(item, picked.value);
  }
}

class _ContextPicker extends StatefulWidget {
  const _ContextPicker({required this.selected, required this.options});

  final Set<String> selected;
  final List<(String, String)> options;

  @override
  State<_ContextPicker> createState() => _ContextPickerState();
}

class _ContextPickerState extends State<_ContextPicker> {
  late final _picked = {...widget.selected};

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              context.l10n.contextsTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          for (final (id, label) in widget.options)
            CheckboxListTile(
              value: _picked.contains(id),
              title: Text(label),
              onChanged: (on) => setState(
                () => on == true ? _picked.add(id) : _picked.remove(id),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: () => Navigator.pop(context, _picked),
              child: Text(context.l10n.commonDone),
            ),
          ),
        ],
      ),
    );
  }
}

/// Phone numbers, email addresses and links found in the notes, as buttons
/// that hand them to the phone's own apps (§4.6).
class NoteLinks extends StatelessWidget {
  const NoteLinks({super.key, required this.notes});

  final String? notes;

  @override
  Widget build(BuildContext context) {
    final links = notes == null ? const <FoundLink>[] : findLinks(notes!);
    if (links.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Semantics(
        container: true,
        label: context.l10n.itemNotesLinks,
        child: Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final link in links)
              ActionChip(
                avatar: Icon(switch (link.kind) {
                  LinkKind.phone => Icons.call_outlined,
                  LinkKind.email => Icons.mail_outline,
                  LinkKind.web => Icons.open_in_new,
                }, size: 18),
                label: Text(link.text, overflow: TextOverflow.ellipsis),
                tooltip: context.l10n.itemOpenLink,
                onPressed: () =>
                    launchUrl(link.uri, mode: LaunchMode.externalApplication),
              ),
          ],
        ),
      ),
    );
  }
}
