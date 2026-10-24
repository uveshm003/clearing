import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/glade.dart';
import '../../core/providers.dart';
import '../../data/speech.dart';
import '../../domain/capture_parser.dart';
import '../../domain/enums.dart';
import '../../domain/item.dart';
import '../../domain/local_date.dart';
import '../../domain/repeat_series.dart';
import '../../domain/search_filter.dart';
import '../../domain/starter_suggestion.dart';
import '../../domain/template.dart';
import '../../l10n/l10n.dart';
import '../format.dart';
import '../guidance/field_notes_hooks.dart';
import '../guidance/tip_card.dart';

/// Opens quick capture (FR-01). [listId] files captures under a list, e.g.
/// when opened from that list's screen.
Future<void> showCaptureSheet(
  BuildContext context, {
  String? initialText,
  String? listId,
  bool listen = false,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) =>
        CaptureSheet(initialText: initialText, listId: listId, listen: listen),
  );
}

class CaptureSheet extends ConsumerStatefulWidget {
  const CaptureSheet({
    super.key,
    this.initialText,
    this.listId,
    this.listen = false,
  });

  final String? initialText;
  final String? listId;

  /// Starts listening straight away (the "Speak" shortcut).
  final bool listen;

  @override
  ConsumerState<CaptureSheet> createState() => _CaptureSheetState();
}

/// One line saved during this burst.
typedef _Saved = ({String id, String title});

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
  final _saved = <_Saved>[];

  /// Understood parts the user took back, by tapping their chip.
  final _ignore = <CapturePart>{};

  /// Where this burst goes: the Inbox (null), Today or This week.
  WhenHorizon? _planAs;

  /// Text shared from another app isn't read for dates until it's edited:
  /// an article's numbers aren't a plan.
  late bool _fromShare = widget.initialText != null;

  /// A capture that looks like something already open.
  ({Item existing, Item added})? _duplicate;

  /// A line about the last save, e.g. that the must-dos were full.
  String? _notice;

  StreamSubscription<SpeechEvent>? _speech;
  bool _listening = false;

  /// Words heard in the phrase still being spoken.
  String _partial = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_changed);
    if (widget.listen) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _toggleListening());
    }
  }

  void _changed() {
    if (_controller.text.isEmpty) _ignore.clear();
    setState(() {});
  }

  @override
  void dispose() {
    _speech?.cancel();
    if (_listening) ref.read(speechGatewayProvider).stop();
    _controller.removeListener(_changed);
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  LocalDate get _today =>
      ref.read(todayProvider).value ?? LocalDate.fromDateTime(DateTime.now());

  bool get _parsing =>
      !_fromShare && (ref.read(settingsProvider).value?.parseCapture ?? true);

  Map<String, String> get _listsByName => {
    for (final list in ref.read(listsProvider).value ?? const [])
      if (!list.archived) list.name: list.id,
  };

  ParsedCapture _parse(String line, {Set<CapturePart>? ignore}) {
    final now = ref.read(clockProvider)();
    final settings = ref.read(settingsProvider).value;
    final locale = Localizations.maybeLocaleOf(context);
    return parseCapture(
      line,
      today: _today,
      nowMinutes: now.hour * 60 + now.minute,
      weekStart: settings?.weekStart ?? DateTime.monday,
      // Only American English reads 3/4 as March 4th.
      dayFirst: locale?.countryCode != 'US',
      lists: _listsByName,
      ignore: ignore ?? _ignore,
    );
  }

  /// The single line being typed, read for chips; null when there's nothing
  /// to show (several lines, a template, or parsing off).
  ParsedCapture? get _preview {
    final text = _controller.text.trim();
    if (!_parsing || text.isEmpty || text.contains('\n')) return null;
    if (text.startsWith('/')) return null;
    final parsed = _parse(text);
    return parsed.isPlain ? null : parsed;
  }

  /// Saves and clears the field but keeps it open for the next thought.
  Future<void> _save([String? text]) async {
    final value = text ?? _controller.text;
    if (value.trim().isEmpty) return;
    final actions = ref.read(itemActionsProvider);
    final settings = ref.read(settingsProvider).value;
    final lines = value
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    final added = <Item>[];
    final fullNotice = context.l10n.captureMustDoFull;
    String? notice;
    for (final line in lines) {
      final parsed = _parsing
          ? _parse(line)
          : ParsedCapture(title: line, original: line);
      final result = await actions.captureParsed(
        parsed,
        listId: widget.listId,
        skipInbox: settings?.parsedSkipInbox ?? true,
        planAs: _planAs,
        mustDoCap: settings?.mustDoCap ?? 3,
        openItems: ref.read(openItemsProvider).value ?? const [],
      );
      if (result.mustDoRefused) notice = fullNotice;
      added.add(result.item);
    }
    if (!mounted) return;
    final duplicate = added.length == 1
        ? await _findDuplicate(added.single)
        : null;
    if (!mounted) return;
    setState(() {
      _saved.insertAll(0, [
        for (final item in added.reversed) (id: item.id, title: item.title),
      ]);
      _ignore.clear();
      _fromShare = false;
      _notice = notice;
      _duplicate = duplicate == null
          ? null
          : (existing: duplicate, added: added.single);
    });
    if (text == null) _controller.clear();
    _focus.requestFocus();
    noteFieldNote(ref, FieldNote.firstLight);
    SemanticsService.sendAnnouncement(
      View.of(context),
      context.l10n.captureSavedAnnouncement(added.length),
      Directionality.of(context),
    );
  }

  /// An open item whose title has every word of [item]'s, if any.
  Future<Item?> _findDuplicate(Item item) async {
    if (item.title.trim().length < 3) return null;
    final found = await ref
        .read(itemRepositoryProvider)
        .search(
          SearchFilter(
            text: item.title,
            statuses: const {
              ItemStatus.inbox,
              ItemStatus.active,
              ItemStatus.waiting,
              ItemStatus.someday,
            },
          ),
        );
    return found.where((i) => i.id != item.id).firstOrNull;
  }

  Future<void> _keepJustOne() async {
    final duplicate = _duplicate;
    if (duplicate == null) return;
    await ref.read(itemRepositoryProvider).deleteForever(duplicate.added.id);
    if (!mounted) return;
    setState(() {
      _saved.removeWhere((s) => s.id == duplicate.added.id);
      _duplicate = null;
      _notice = context.l10n.captureDuplicateMerged;
    });
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
    setState(
      () => _saved.insertAll(0, [
        for (final item in items.reversed) (id: item.id, title: item.title),
      ]),
    );
  }

  Future<void> _startTemplate(Template template) async {
    var item = await ref.read(templateActionsProvider).start(template);
    final actions = ref.read(itemActionsProvider);
    item = switch (_planAs) {
      WhenHorizon.today => await actions.planToday(item),
      WhenHorizon.thisWeek => await actions.planThisWeek(item),
      _ => item,
    };
    if (!mounted) return;
    _controller.clear();
    setState(
      () => _saved.insert(0, (
        id: item.id,
        title: context.l10n.captureTemplateStarted(template.name),
      )),
    );
  }

  /// Tapping a saved line: fix a typo, or take it back.
  Future<void> _editSaved(_Saved saved) async {
    final controller = TextEditingController(text: saved.title);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.captureEditSaved),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: null,
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ''),
            child: Text(context.l10n.captureRemoveSaved),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(context.l10n.commonSave),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result == null || !mounted) return;
    final items = ref.read(itemRepositoryProvider);
    if (result.trim().isEmpty) {
      await items.deleteForever(saved.id);
      if (mounted) setState(() => _saved.remove(saved));
      return;
    }
    final item = await items.getItem(saved.id);
    if (item == null) return;
    await ref
        .read(itemActionsProvider)
        .save(item.copyWith(title: result.trim()));
    if (!mounted) return;
    setState(() {
      final i = _saved.indexOf(saved);
      if (i >= 0) _saved[i] = (id: saved.id, title: result.trim());
    });
  }

  Future<void> _toggleListening() async {
    final speech = ref.read(speechGatewayProvider);
    if (_listening) {
      await speech.stop();
      return;
    }
    final locale = Localizations.localeOf(context);
    final tag = locale.languageCode == 'hi' ? 'hi-IN' : locale.toLanguageTag();
    setState(() {
      _listening = true;
      _partial = '';
    });
    noteFieldNote(ref, FieldNote.fromTheDoorstep);
    _speech = speech.listen(tag).listen((event) {
      if (!mounted) return;
      switch (event) {
        case SpeechWords(:final text, isFinal: false):
          setState(() => _partial = text);
        case SpeechWords(:final text, isFinal: true):
          // A pause ends a phrase: each phrase becomes its own line.
          final current = _controller.text.trimRight();
          _controller.text = [
            if (current.isNotEmpty) current,
            text.trim(),
          ].join('\n');
          setState(() => _partial = '');
        case SpeechFailed():
          setState(() {
            _listening = false;
            _notice = context.l10n.captureVoiceFailed;
          });
        case SpeechDone():
          setState(() => _listening = false);
      }
    }, onDone: () => mounted ? setState(() => _listening = false) : null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider).value;
    final today = ref.watch(todayProvider).value ?? _today;
    final suggestions = (settings?.starterSuggestions ?? false)
        ? (ref.watch(suggestionsProvider).value ?? const [])
              .where((s) => s.enabled)
              .toList()
        : const <StarterSuggestion>[];
    final lists = ref.watch(listsProvider).value ?? const [];
    final listName = widget.listId == null
        ? null
        : lists.where((l) => l.id == widget.listId).firstOrNull?.name;
    final preview = _preview;
    final text = _controller.text.trim();
    final templates = text.startsWith('/')
        ? (ref.watch(templatesProvider).value ?? const <Template>[])
              .where(
                (t) => t.name.toLowerCase().contains(
                  text.substring(1).trim().toLowerCase(),
                ),
              )
              .take(6)
              .toList()
        : const <Template>[];
    final canListen = ref.watch(speechAvailableProvider).value ?? false;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_saved.isNotEmpty)
              _SavedStack(saved: _saved, onTap: _editSaved),
            if (_duplicate case final duplicate?)
              _DuplicateHint(
                title: duplicate.existing.title,
                onMerge: _keepJustOne,
                onKeep: () => setState(() => _duplicate = null),
              ),
            if (_notice case final notice?)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    notice,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 8, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focus,
                      autofocus: !widget.listen,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.done,
                      style: theme.textTheme.titleMedium,
                      decoration: InputDecoration(
                        hintText: _listening && _partial.isNotEmpty
                            ? _partial
                            : context.l10n.captureHint,
                        helperText: _listening
                            ? context.l10n.captureVoiceListening
                            // A line with a date or Today won't wait in the
                            // Inbox, so don't say it will.
                            : (preview?.hasPlan ?? false) &&
                                  (settings?.parsedSkipInbox ?? true)
                            ? null
                            : listName == null
                            ? context.l10n.captureHelper
                            : context.l10n.captureHelperInList(listName),
                        helperMaxLines: 2,
                      ),
                      onChanged: (_) => _fromShare = false,
                      onSubmitted: (_) => _save(),
                    ),
                  ),
                  if (canListen)
                    IconButton(
                      icon: Icon(
                        _listening
                            ? Icons.stop_circle_outlined
                            : Icons.mic_none,
                      ),
                      tooltip: _listening
                          ? context.l10n.captureVoiceStop
                          : context.l10n.captureVoice,
                      onPressed: _toggleListening,
                    ),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.arrow_upward),
                    tooltip: context.l10n.commonSave,
                    onPressed: _save,
                  ),
                ],
              ),
            ),
            if (preview != null)
              _UnderstoodChips(
                parsed: preview,
                today: today,
                listName: lists
                    .where((l) => l.id == preview.listId)
                    .firstOrNull
                    ?.name,
                onRemove: (part) => setState(() => _ignore.add(part)),
              ),
            if (templates.isNotEmpty)
              _TemplateRow(templates: templates, onPick: _startTemplate),
            _DestinationRow(
              value: _planAs,
              onChanged: (value) => setState(() => _planAs = value),
            ),
            TipCard(
              id: Tips.captureBurst,
              text: context.l10n.tipCaptureBurst,
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
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
                        padding: const EdgeInsetsDirectional.only(end: 8),
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
              alignment: AlignmentDirectional.centerEnd,
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
      ),
    );
  }

  static IconData _iconFor(ListKind? kind) => switch (kind) {
    ListKind.lifeAdmin => Icons.receipt_long_outlined,
    ListKind.errands => Icons.shopping_bag_outlined,
    _ => Icons.add,
  };
}

/// The parts smart capture understood, as chips; tapping one keeps its words
/// in the title instead (FR-01a). Nothing is taken out silently.
class _UnderstoodChips extends StatelessWidget {
  const _UnderstoodChips({
    required this.parsed,
    required this.today,
    required this.listName,
    required this.onRemove,
  });

  final ParsedCapture parsed;
  final LocalDate today;
  final String? listName;
  final void Function(CapturePart part) onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final chips = <(CapturePart, IconData, String)>[
      if (parsed.repeat case final rule?)
        (
          CapturePart.repeat,
          Icons.repeat,
          describeRepeat(
            RepeatSeries(
              id: '',
              freq: rule.freq,
              interval: rule.interval,
              weekdays: rule.weekdays,
              monthDay: rule.monthDay,
              startDate: parsed.date ?? today,
              onMissed: OnMissed.carryOver,
              template: const SeriesTemplate(title: ''),
            ),
            today,
          ),
        )
      else if (parsed.date case final date?)
        (CapturePart.when, Icons.event_outlined, dateLabel(date, today))
      else if (parsed.horizon case final horizon?)
        (
          CapturePart.when,
          Icons.event_outlined,
          horizon == WhenHorizon.today ? l10n.whenToday : l10n.whenThisWeek,
        ),
      if (parsed.time case final time?)
        (CapturePart.time, Icons.schedule, timeLabel(context, time)),
      if (parsed.deadline case final deadline?)
        (
          CapturePart.deadline,
          Icons.flag_outlined,
          l10n.captureChipDue(dateLabel(deadline, today)),
        ),
      if (listName case final name?)
        (CapturePart.list, Icons.list_alt_outlined, name),
      if (parsed.mustDo)
        (CapturePart.mustDo, Icons.star_rounded, l10n.captureChipMustDo),
      if (parsed.waitingOn case final person?)
        (
          CapturePart.waiting,
          Icons.person_outline,
          l10n.captureChipWaiting(person),
        ),
      if (parsed.effort case final effort?)
        (CapturePart.effort, Icons.timelapse, effortLabel(effort)),
    ];
    return Semantics(
      container: true,
      label: l10n.captureUnderstood,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final (part, icon, label) in chips)
              InputChip(
                avatar: Icon(icon, size: 18),
                label: Text(label),
                onDeleted: () => onRemove(part),
                deleteButtonTooltipMessage: l10n.captureChipRemove(label),
                onPressed: () => onRemove(part),
              ),
          ],
        ),
      ),
    );
  }
}

class _TemplateRow extends StatelessWidget {
  const _TemplateRow({required this.templates, required this.onPick});

  final List<Template> templates;
  final void Function(Template template) onPick;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.captureTemplates,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          Wrap(
            spacing: 8,
            children: [
              for (final template in templates)
                ActionChip(
                  avatar: const Icon(Icons.checklist, size: 18),
                  label: Text(template.name),
                  onPressed: () => onPick(template),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Inbox (the default) · Today · This week, for the whole burst.
class _DestinationRow extends StatelessWidget {
  const _DestinationRow({required this.value, required this.onChanged});

  final WhenHorizon? value;
  final ValueChanged<WhenHorizon?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Semantics(
        container: true,
        label: l10n.captureDestination,
        child: Wrap(
          spacing: 8,
          children: [
            for (final (horizon, label) in [
              (null, l10n.captureToInbox),
              (WhenHorizon.today, l10n.whenToday),
              (WhenHorizon.thisWeek, l10n.whenThisWeek),
            ])
              ChoiceChip(
                label: Text(label),
                selected: value == horizon,
                onSelected: (_) => onChanged(horizon),
              ),
          ],
        ),
      ),
    );
  }
}

class _DuplicateHint extends StatelessWidget {
  const _DuplicateHint({
    required this.title,
    required this.onMerge,
    required this.onKeep,
  });

  final String title;
  final VoidCallback onMerge;
  final VoidCallback onKeep;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Material(
        color: scheme.surfaceContainerHigh,
        borderRadius: const BorderRadius.all(Radius.circular(GladeSpace.md)),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 8, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                liveRegion: true,
                child: Text(context.l10n.captureDuplicate(title)),
              ),
              Wrap(
                alignment: WrapAlignment.end,
                children: [
                  TextButton(
                    onPressed: onKeep,
                    child: Text(context.l10n.captureDuplicateKeep),
                  ),
                  TextButton(
                    onPressed: onMerge,
                    child: Text(context.l10n.captureDuplicateMerge),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Glade's "Emptying your head": each thought saved in burst mode slides up
/// into a small stack above the field, newest in front, the older ones
/// fading back, with a count. Tapping one edits or removes it.
class _SavedStack extends StatelessWidget {
  const _SavedStack({required this.saved, required this.onTap});

  /// Newest first.
  final List<_Saved> saved;
  final void Function(_Saved saved) onTap;

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
          for (final (i, entry) in shown.indexed.toList().reversed)
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
                key: ValueKey('${entry.id}:${entry.title}'),
                opacity: const [1.0, 0.7, 0.45][i],
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Material(
                    color: scheme.surfaceContainerHigh,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(GladeSpace.md),
                    ),
                    child: InkWell(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(GladeSpace.md),
                      ),
                      onTap: () => onTap(entry),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Text(
                          entry.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
