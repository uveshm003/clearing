import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/enums.dart';
import '../../domain/item.dart';
import '../../domain/local_date.dart';
import '../../domain/search_filter.dart';
import '../../l10n/l10n.dart';
import '../format.dart';
import '../../domain/app_settings.dart';
import '../selection.dart';
import '../widgets/empty_state.dart';
import '../widgets/item_tile.dart';

/// The status chips, each standing for a group of statuses.
List<(String, Set<ItemStatus>)> _statusGroups(AppLocalizations strings) => [
  (
    strings.searchStatusOpen,
    const {ItemStatus.inbox, ItemStatus.active, ItemStatus.waiting},
  ),
  (strings.someday, const {ItemStatus.someday}),
  (strings.commonDone, const {ItemStatus.done}),
];

/// Search and filters across every item but Trash (FR-16).
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _text = TextEditingController();
  var _filter = const SearchFilter();
  Future<List<Item>>? _results;
  Future<Map<String, String>>? _snippets;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _run();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _text.dispose();
    super.dispose();
  }

  void _run() {
    final repository = ref.read(itemRepositoryProvider);
    final results = repository.search(_filter);
    final snippets = repository.snippets(_filter.text);
    setState(() {
      _results = results;
      _snippets = snippets;
    });
  }

  /// Keeps what was searched for, newest first, for next time.
  Future<void> _remember() async {
    final text = _filter.text.trim();
    if (text.length < 2) return;
    final repository = ref.read(settingsRepositoryProvider);
    final settings = await repository.get();
    await repository.save(
      settings.copyWith(
        recentSearches: [
          text,
          ...settings.recentSearches.where((t) => t != text),
        ].take(AppSettings.maxRecentSearches).toList(),
      ),
    );
  }

  Future<void> _saveSearch() async {
    final controller = TextEditingController(text: _filter.text.trim());
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.savedSearchName),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(context.l10n.commonSave),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.trim().isEmpty || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final saved = context.l10n.savedSearchSaved;
    await ref.read(savedSearchRepositoryProvider).create(name, _filter);
    messenger.showSnackBar(SnackBar(content: Text(saved)));
  }

  void _setFilter(SearchFilter filter) {
    _filter = filter;
    _run();
  }

  void _textChanged(String text) {
    _filter = _filter.copyWith(text: text);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 150), _run);
  }

  /// No status chip selected means every status but Trash.
  bool get _allStatuses => const SetEquality<ItemStatus>().equals(
    _filter.statuses,
    SearchFilter.defaultStatuses,
  );

  bool _groupOn(Set<ItemStatus> group) =>
      !_allStatuses && group.every(_filter.statuses.contains);

  void _toggleGroup(Set<ItemStatus> group) {
    final next = _allStatuses
        ? group
        : _groupOn(group)
        ? _filter.statuses.difference(group)
        : {..._filter.statuses, ...group};
    _setFilter(
      _filter.copyWith(
        statuses: next.isEmpty ? SearchFilter.defaultStatuses : next,
      ),
    );
  }

  Future<void> _pickDates(LocalDate today) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: dateTimeOf(today.addDays(-365 * 5)),
      lastDate: dateTimeOf(today.addDays(365 * 5)),
      initialDateRange: _filter.hasDateRange
          ? DateTimeRange(
              start: dateTimeOf(_filter.from ?? today),
              end: dateTimeOf(_filter.to ?? today),
            )
          : null,
      helpText: context.l10n.searchPlannedBetween,
    );
    if (range == null) return;
    _setFilter(
      _filter.copyWith(
        from: () => LocalDate.fromDateTime(range.start),
        to: () => LocalDate.fromDateTime(range.end),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today =
        ref.watch(todayProvider).value ??
        LocalDate.fromDateTime(DateTime.now());
    final lists = ref.watch(listsProvider).value ?? const [];
    final listName = lists
        .where((l) => l.id == _filter.listId)
        .firstOrNull
        ?.name;
    // Re-run when items change, e.g. after completing a result.
    ref.listen(openItemsProvider, (_, _) => _run());
    final contexts = ref.watch(contextsProvider).value ?? const [];
    final contextName = contexts
        .where((c) => c.id == _filter.contextId)
        .map(contextLabel)
        .firstOrNull;
    final recent =
        ref.watch(settingsProvider).value?.recentSearches ?? const [];
    final selecting = ref.watch(selectionProvider).isNotEmpty;

    return SelectionScope(
      child: Scaffold(
        bottomNavigationBar: selecting ? const SelectionBar() : null,
        appBar: AppBar(
          title: TextField(
            controller: _text,
            autofocus: true,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: context.l10n.searchHint,
              border: InputBorder.none,
            ),
            onChanged: _textChanged,
            onSubmitted: (_) => _remember(),
          ),
          actions: [
            if (_filter.text.trim().isNotEmpty || _filter.isNarrowed)
              IconButton(
                icon: const Icon(Icons.bookmark_add_outlined),
                tooltip: context.l10n.savedSearchSave,
                onPressed: _saveSearch,
              ),
            if (_text.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: context.l10n.searchClear,
                onPressed: () {
                  _text.clear();
                  _textChanged('');
                },
              ),
          ],
        ),
        body: Column(
          children: [
            // Tall enough for each chip's full 48 dp touch target (FR-20).
            SizedBox(
              height: 64,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                children: [
                  for (final (label, group) in _statusGroups(context.l10n))
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
                      child: FilterChip(
                        label: Text(label),
                        selected: _groupOn(group),
                        onSelected: (_) => _toggleGroup(group),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: MenuAnchor(
                      builder: (context, menu, _) => FilterChip(
                        label: Text(listName ?? context.l10n.searchAnyList),
                        selected: listName != null,
                        onSelected: (_) =>
                            menu.isOpen ? menu.close() : menu.open(),
                      ),
                      menuChildren: [
                        MenuItemButton(
                          onPressed: () =>
                              _setFilter(_filter.copyWith(listId: () => null)),
                          child: Text(context.l10n.searchAnyList),
                        ),
                        for (final list in lists)
                          MenuItemButton(
                            onPressed: () => _setFilter(
                              _filter.copyWith(listId: () => list.id),
                            ),
                            child: Text(list.name),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: _filter.hasDateRange
                        ? InputChip(
                            label: Text(
                              context.l10n.searchDateRange(
                                dateLabel(_filter.from!, today),
                                dateLabel(_filter.to!, today),
                              ),
                            ),
                            selected: true,
                            onPressed: () => _pickDates(today),
                            onDeleted: () => _setFilter(
                              _filter.copyWith(
                                from: () => null,
                                to: () => null,
                              ),
                            ),
                            deleteButtonTooltipMessage:
                                context.l10n.searchAnyDate,
                          )
                        : FilterChip(
                            label: Text(context.l10n.searchAnyDate),
                            onSelected: (_) => _pickDates(today),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: FilterChip(
                      label: Text(context.l10n.searchRepeating),
                      selected: _filter.repeating ?? false,
                      onSelected: (on) => _setFilter(
                        _filter.copyWith(repeating: () => on ? true : null),
                      ),
                    ),
                  ),
                  if (contexts.isNotEmpty)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
                      child: MenuAnchor(
                        builder: (context, menu, _) => FilterChip(
                          label: Text(
                            contextName ?? context.l10n.searchAnyContext,
                          ),
                          selected: contextName != null,
                          onSelected: (_) =>
                              menu.isOpen ? menu.close() : menu.open(),
                        ),
                        menuChildren: [
                          MenuItemButton(
                            onPressed: () => _setFilter(
                              _filter.copyWith(contextId: () => null),
                            ),
                            child: Text(context.l10n.searchAnyContext),
                          ),
                          for (final c in contexts)
                            MenuItemButton(
                              onPressed: () => _setFilter(
                                _filter.copyWith(contextId: () => c.id),
                              ),
                              child: Text(contextLabel(c)),
                            ),
                        ],
                      ),
                    ),
                  MenuAnchor(
                    builder: (context, menu, _) => FilterChip(
                      label: Text(
                        _filter.maxEffort == null
                            ? context.l10n.searchAnyEffort
                            : context.l10n.searchUpTo(
                                effortLabel(_filter.maxEffort!),
                              ),
                      ),
                      selected: _filter.maxEffort != null,
                      onSelected: (_) =>
                          menu.isOpen ? menu.close() : menu.open(),
                    ),
                    menuChildren: [
                      MenuItemButton(
                        onPressed: () =>
                            _setFilter(_filter.copyWith(maxEffort: () => null)),
                        child: Text(context.l10n.searchAnyEffort),
                      ),
                      for (final minutes in Item.effortSteps.take(4))
                        MenuItemButton(
                          onPressed: () => _setFilter(
                            _filter.copyWith(maxEffort: () => minutes),
                          ),
                          child: Text(
                            context.l10n.searchUpTo(effortLabel(minutes)),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (_filter.text.isEmpty && recent.isNotEmpty)
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 8, 0),
                child: Row(
                  children: [
                    Text(
                      context.l10n.searchRecent,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          children: [
                            for (final text in recent)
                              Padding(
                                padding: const EdgeInsetsDirectional.only(
                                  end: 8,
                                ),
                                child: ActionChip(
                                  avatar: const Icon(Icons.history, size: 18),
                                  label: Text(text),
                                  onPressed: () {
                                    _text.text = text;
                                    _textChanged(text);
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final repository = ref.read(settingsRepositoryProvider);
                        final settings = await repository.get();
                        await repository.save(
                          settings.copyWith(recentSearches: const []),
                        );
                      },
                      child: Text(context.l10n.searchClearRecent),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: FutureBuilder(
                future: _results,
                builder: (context, snapshot) {
                  final results = snapshot.data;
                  if (results == null) return const SizedBox.shrink();
                  if (results.isEmpty) {
                    return EmptyState(
                      icon: Icons.search_off,
                      title: context.l10n.searchNoMatchesTitle,
                      message: context.l10n.searchNoMatchesMessage,
                    );
                  }
                  return FutureBuilder(
                    future: _snippets,
                    builder: (context, snippets) => ListView(
                      padding: const EdgeInsets.only(bottom: 32),
                      children: [
                        for (final item in results)
                          _Result(
                            item: item,
                            snippet: snippets.data?[item.id],
                            onOpen: _remember,
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A result, with the matching words from its notes or steps under it when
/// the match isn't in the title.
class _Result extends StatelessWidget {
  const _Result({
    required this.item,
    required this.snippet,
    required this.onOpen,
  });

  final Item item;

  /// From FTS5, with the match between ‹ and ›.
  final String? snippet;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final excerpt = snippet;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Listener(
          onPointerUp: (_) => onOpen(),
          child: ItemTile(item: item, swipe: true),
        ),
        if (excerpt != null && excerpt.contains('‹'))
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(64, 0, 16, 8),
            child: Text.rich(
              TextSpan(
                children: [
                  for (final (i, part) in excerpt.split(RegExp('[‹›]')).indexed)
                    TextSpan(
                      text: part,
                      style: i.isOdd
                          ? const TextStyle(fontWeight: FontWeight.w700)
                          : null,
                    ),
                ],
              ),
              maxLines: 2,
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
