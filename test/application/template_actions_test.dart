import 'package:clearing/application/item_actions.dart';
import 'package:clearing/application/series_actions.dart';
import 'package:clearing/application/template_actions.dart';
import 'package:clearing/data/db/database.dart';
import 'package:clearing/data/item_repository.dart';
import 'package:clearing/data/reminder_repository.dart';
import 'package:clearing/data/series_repository.dart';
import 'package:clearing/data/template_repository.dart';
import 'package:clearing/domain/enums.dart';
import 'package:clearing/domain/item.dart';
import 'package:clearing/domain/local_date.dart';
import 'package:clearing/domain/repeat_series.dart';
import 'package:clearing/domain/template.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;
  late ItemRepository items;
  late SeriesRepository seriesRepo;
  late TemplateRepository templates;
  late ItemActions actions;
  late TemplateActions templateActions;
  var now = DateTime(2026, 10, 20, 9); // Tuesday

  setUp(() {
    now = DateTime(2026, 10, 20, 9);
    DateTime clock() => now;
    db = memoryDatabase(now: clock);
    items = ItemRepository(db, now: clock);
    seriesRepo = SeriesRepository(db, now: clock);
    templates = TemplateRepository(db, now: clock);
    final series = SeriesActions(
      db,
      seriesRepo,
      items,
      ReminderRepository(db, now: clock),
      now: clock,
    );
    actions = ItemActions(items, now: clock, series: series);
    templateActions = TemplateActions(
      db,
      templates,
      items,
      actions,
      seriesRepo,
      series,
    );
  });
  tearDown(() => db.close());

  Future<List<String>> steps(Item item) async => [
    for (final s in await items.subtasksOf(item.id)) s.title,
  ];

  test('starting makes an independent checklist copy', () async {
    final packing = await templateActions.create(
      'Packing list',
      steps: ['Charger', 'Toothbrush'],
      doneMeans: 'Bag by the door',
    );
    final item = await templateActions.start(packing);
    expect(item.status, ItemStatus.inbox);
    expect(item.title, 'Packing list');
    expect(item.doneMeans, 'Bag by the door');
    expect(await steps(item), ['Charger', 'Toothbrush']);

    await templateActions.save(
      packing.copyWith(name: 'Trip list', steps: ['Passport']),
    );
    expect((await items.getItem(item.id))!.title, 'Packing list');
    expect(await steps(item), ['Charger', 'Toothbrush']);
  });

  RepeatSeries weekdays() => RepeatSeries(
    id: 's1',
    freq: RepeatFrequency.weekly,
    weekdays: const {1, 2, 3, 4, 5},
    startDate: LocalDate(2026, 10, 20),
    onMissed: OnMissed.skip,
    template: const SeriesTemplate(title: ''),
  );

  Future<List<Item>> open() async => [
    for (final i in await seriesRepo.occurrences('s1'))
      if (i.status == ItemStatus.active) i,
  ];

  test('a routine arrives as a fresh checklist each time', () async {
    final morning = await templateActions.create(
      'Morning routine',
      steps: ['Water', 'Stretch'],
    );
    final routine = await templateActions.makeRoutine(morning, weekdays());
    expect(routine.isRoutine, isTrue);
    expect((await templates.get(morning.id))!.kind, TemplateKind.routine);

    final [first] = await open();
    expect(first.doDate, LocalDate(2026, 10, 20));
    expect(await steps(first), ['Water', 'Stretch']);

    // Editing changes the next ones, not the one already made.
    await templateActions.save(routine.copyWith(steps: ['Water', 'Walk']));
    await actions.complete(first);
    final [second] = await open();
    expect(second.doDate, LocalDate(2026, 10, 21));
    expect(await steps(second), ['Water', 'Walk']);
    expect(await steps(first), ['Water', 'Stretch']);
  });

  test('stopping a routine keeps the template and the open item', () async {
    final morning = await templateActions.create('Morning', steps: ['Water']);
    final routine = await templateActions.makeRoutine(morning, weekdays());
    final [openItem] = await open();

    final stopped = await templateActions.stopRoutine(routine);
    expect(stopped.isRoutine, isFalse);
    expect(await seriesRepo.get('s1'), isNull);
    final kept = (await items.getItem(openItem.id))!;
    expect(kept.status, ItemStatus.active);
    expect(kept.seriesId, isNull);
  });

  test('deleting a routine template stops it first', () async {
    final morning = await templateActions.create('Morning');
    final routine = await templateActions.makeRoutine(morning, weekdays());
    await templateActions.delete(routine);
    expect(await templates.get(morning.id), isNull);
    expect(await seriesRepo.get('s1'), isNull);
  });

  test('stored JSON tolerates damage', () {
    final t = Template.fromRow(
      id: 't',
      name: 'x',
      items: {
        'steps': ['a', 3, 'b'],
        'doneMeans': 7,
      },
    );
    expect(t.steps, ['a', 'b']);
    expect(t.doneMeans, isNull);
    expect(Template.fromRow(id: 't', name: 'x', items: 'nope').steps, isEmpty);
  });
}
