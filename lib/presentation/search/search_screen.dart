import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/enums.dart';
import '../../domain/item.dart';
import '../../domain/local_date.dart';
import '../../domain/search_filter.dart';
import '../format.dart';
import '../widgets/empty_state.dart';
import '../widgets/item_tile.dart';

/// The status chips, each standing for a group of statuses.
const _statusGroups = <(String, Set<ItemStatus>)>[
  ('Open', {ItemStatus.inbox, ItemStatus.active, ItemStatus.waiting}),
  ('Someday', {ItemStatus.someday}),
  ('Done', {ItemStatus.done}),
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
    final results = ref.read(itemRepositoryProvider).search(_filter);
    setState(() {
      _results = results;
    });
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
      helpText: 'Planned between',
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

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _text,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Search titles, notes and steps',
            border: InputBorder.none,
          ),
          onChanged: _textChanged,
        ),
        actions: [
          if (_text.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Clear',
              onPressed: () {
                _text.clear();
                _textChanged('');
              },
            ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                for (final (label, group) in _statusGroups)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(label),
                      selected: _groupOn(group),
                      onSelected: (_) => _toggleGroup(group),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: MenuAnchor(
                    builder: (context, menu, _) => FilterChip(
                      label: Text(listName ?? 'Any list'),
                      selected: listName != null,
                      onSelected: (_) =>
                          menu.isOpen ? menu.close() : menu.open(),
                    ),
                    menuChildren: [
                      MenuItemButton(
                        onPressed: () =>
                            _setFilter(_filter.copyWith(listId: () => null)),
                        child: const Text('Any list'),
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
                  padding: const EdgeInsets.only(right: 8),
                  child: _filter.hasDateRange
                      ? InputChip(
                          label: Text(
                            '${dateLabel(_filter.from!, today)} – '
                            '${dateLabel(_filter.to!, today)}',
                          ),
                          selected: true,
                          onPressed: () => _pickDates(today),
                          onDeleted: () => _setFilter(
                            _filter.copyWith(from: () => null, to: () => null),
                          ),
                          deleteButtonTooltipMessage: 'Any date',
                        )
                      : FilterChip(
                          label: const Text('Any date'),
                          onSelected: (_) => _pickDates(today),
                        ),
                ),
                FilterChip(
                  label: const Text('Repeating'),
                  selected: _filter.repeating ?? false,
                  onSelected: (on) => _setFilter(
                    _filter.copyWith(repeating: () => on ? true : null),
                  ),
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
                  return const EmptyState(
                    icon: Icons.search_off,
                    title: 'No matches',
                    message: 'Try fewer words, or loosen the filters.',
                  );
                }
                return ListView(
                  padding: const EdgeInsets.only(bottom: 32),
                  children: [for (final item in results) ItemTile(item: item)],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
