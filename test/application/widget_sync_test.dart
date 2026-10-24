import 'package:clearing/application/item_actions.dart';
import 'package:clearing/application/widget_sync.dart';
import 'package:clearing/data/db/database.dart';
import 'package:clearing/data/home_widgets.dart';
import 'package:clearing/data/item_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

class _FakeWidgets implements HomeWidgetGateway {
  TodayWidgetData? shown;

  @override
  Future<void> showToday(TodayWidgetData data) async => shown = data;

  @override
  Future<void> showGrove(Widget picture, Size size) async {}
}

void main() {
  late AppDatabase db;
  late ItemActions actions;
  late _FakeWidgets widgets;
  late WidgetSync sync;
  final now = DateTime(2026, 10, 20, 9);

  setUp(() {
    db = memoryDatabase(now: () => now);
    final items = ItemRepository(db, now: () => now);
    actions = ItemActions(items, now: () => now);
    widgets = _FakeWidgets();
    sync = WidgetSync(items, widgets, now: () => now);
  });
  tearDown(() => db.close());

  List<String> titles() => [for (final r in widgets.shown!.rows) r.title];

  test('shows must-dos, and counts the rest of Today', () async {
    final [a, b, c] = await actions.capture('Rent\nDentist\nMilk');
    for (final item in [a, b, c]) {
      await actions.planToday(item);
    }
    await actions.save((await actions.get(a.id))!.copyWith(mustDo: true));
    await sync.refresh();
    expect(titles(), ['Rent']);
    expect(widgets.shown!.more, 2);
  });

  test('falls back to Today items when there are no must-dos', () async {
    final items = await actions.capture('1\n2\n3\n4\n5\n6\n7');
    for (final item in items) {
      await actions.planToday(item);
    }
    await sync.refresh();
    expect(titles(), ['1', '2', '3', '4', '5']);
    expect(widgets.shown!.more, 2);
  });

  test('completing removes the row', () async {
    final [a] = await actions.capture('Rent');
    final planned = await actions.planToday(a);
    await sync.refresh();
    expect(titles(), ['Rent']);
    await actions.complete(planned);
    await sync.refresh();
    expect(titles(), isEmpty);
  });

  test('data is what the native widget reads', () {
    const data = TodayWidgetData(
      rows: [(id: 'i1', title: 'Rent')],
      more: 3,
      inbox: 2,
    );
    expect(data.toJson(), {
      'rows': [
        {'id': 'i1', 'title': 'Rent'},
      ],
      'more': 3,
      'inbox': 2,
    });
  });

  test('widget links', () {
    expect(
      WidgetLink.parse(Uri.parse('clearing://capture')),
      isA<CaptureLink>(),
    );
    expect(WidgetLink.parse(Uri.parse('clearing://today')), isA<TodayLink>());
    expect(
      WidgetLink.parse(Uri.parse('clearing://item/abc')),
      isA<ItemLink>().having((l) => l.id, 'id', 'abc'),
    );
    expect(
      WidgetLink.parse(Uri.parse('clearing://complete?id=a%2Fb')),
      isA<CompleteLink>().having((l) => l.id, 'id', 'a/b'),
    );
    expect(WidgetLink.parse(Uri.parse('https://example.com')), isNull);
    expect(WidgetLink.parse(Uri.parse('clearing://item')), isNull);
    expect(WidgetLink.parse(null), isNull);
  });
}
