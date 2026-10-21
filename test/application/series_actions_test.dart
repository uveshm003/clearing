import 'package:clearing/application/item_actions.dart';
import 'package:clearing/application/series_actions.dart';
import 'package:clearing/data/db/database.dart';
import 'package:clearing/data/item_repository.dart';
import 'package:clearing/data/reminder_repository.dart';
import 'package:clearing/data/series_repository.dart';
import 'package:clearing/domain/enums.dart';
import 'package:clearing/domain/item.dart';
import 'package:clearing/domain/local_date.dart';
import 'package:clearing/domain/repeat_series.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;
  late ItemRepository items;
  late SeriesRepository seriesRepo;
  late ReminderRepository reminders;
  late SeriesActions series;
  late ItemActions actions;
  var now = DateTime(2026, 10, 20, 9);
  LocalDate day(int d) => LocalDate(2026, 10, d);

  setUp(() {
    now = DateTime(2026, 10, 20, 9);
    DateTime clock() => now;
    db = memoryDatabase(now: clock);
    items = ItemRepository(db, now: clock);
    seriesRepo = SeriesRepository(db, now: clock);
    reminders = ReminderRepository(db, now: clock);
    series = SeriesActions(db, seriesRepo, items, reminders, now: clock);
    actions = ItemActions(items, now: clock, series: series);
  });
  tearDown(() => db.close());

  RepeatSeries draft({
    RepeatFrequency freq = RepeatFrequency.daily,
    OnMissed onMissed = OnMissed.carryOver,
    LocalDate? start,
    LocalDate? end,
  }) => RepeatSeries(
    id: 's1',
    freq: freq,
    startDate: start ?? day(20),
    endDate: end,
    onMissed: onMissed,
    template: const SeriesTemplate(title: ''),
  );

  Future<Item> repeating({
    OnMissed onMissed = OnMissed.carryOver,
    LocalDate? end,
  }) async {
    final [captured] = await actions.capture('Water plants');
    final item = await actions.planOnDate(captured, day(20), time: 8 * 60);
    await items.addSubtask(item.id, 'Balcony');
    await reminders.add(item.id, offsetMinutes: 10);
    await series.startRepeating(item, draft(onMissed: onMissed, end: end));
    return (await items.getItem(item.id))!;
  }

  Future<List<Item>> open() async => [
    for (final i in await seriesRepo.occurrences('s1'))
      if (i.status != ItemStatus.done && i.status != ItemStatus.trashed) i,
  ];

  test('starting a series makes the item its first occurrence', () async {
    final item = await repeating();
    expect(item.seriesId, 's1');
    expect(item.occurrenceDate, day(20));
    final template = (await seriesRepo.get('s1'))!.template;
    expect(template.title, 'Water plants');
    expect(template.doTime, 8 * 60);
    expect(template.subtasks, ['Balcony']);
    expect(template.reminderOffsets, [10]);
  });

  test('completing creates the next occurrence from the template', () async {
    await actions.complete(await repeating());

    final [next] = await open();
    expect(next.doDate, day(21));
    expect(next.doTime, 8 * 60);
    expect(next.title, 'Water plants');
    expect((await items.subtasksOf(next.id)).single.title, 'Balcony');
    expect((await reminders.forItem(next.id)).single.offsetMinutes, 10);
  });

  test('undoing a completion removes the occurrence it created', () async {
    final item = await repeating();
    await actions.complete(item);
    await actions.undo(item);
    expect((await open()).map((i) => i.id), [item.id]);
  });

  test('a carried-over occurrence blocks the next until done', () async {
    final item = await repeating();
    now = DateTime(2026, 10, 23, 9);
    await series.advanceAll();
    expect((await open()).map((i) => i.id), [item.id]);

    // Done three days late: the next one is today, not a backlog of three.
    await actions.complete(item);
    final [next] = await open();
    expect(next.doDate, day(23));
  });

  test('a skipped occurrence goes quietly and only today is created', () async {
    final item = await repeating(onMissed: OnMissed.skip);
    now = DateTime(2026, 10, 23, 0, 1);
    await series.advanceAll();

    expect((await items.getItem(item.id))!.status, ItemStatus.trashed);
    final [next] = await open();
    expect(next.doDate, day(23));
  });

  test('advancing twice on the same day is a no-op', () async {
    await repeating(onMissed: OnMissed.skip);
    now = DateTime(2026, 10, 22, 9);
    await series.advanceAll();
    await series.advanceAll();
    expect(await open(), hasLength(1));
  });

  test('deleting an occurrence skips just that one', () async {
    await actions.trash(await repeating());
    final [next] = await open();
    expect(next.doDate, day(21));
  });

  test('a paused series creates nothing until resumed', () async {
    await actions.complete(await repeating());
    final [tomorrow] = await open();
    await actions.complete(tomorrow);
    final [afterThat] = await open();
    await items.deleteForever(afterThat.id);

    final s = (await seriesRepo.get('s1'))!;
    await seriesRepo.save(s.copyWith(paused: true));
    now = DateTime(2026, 10, 25, 9);
    await series.advanceAll();
    expect(await open(), isEmpty);

    await seriesRepo.save(s.copyWith(paused: false));
    await series.advanceAll();
    expect((await open()).single.doDate, day(25));
  });

  test('nothing is created after the end date', () async {
    await actions.complete(await repeating(end: day(20)));
    expect(await open(), isEmpty);
  });

  test('changing the rule moves the open occurrence', () async {
    final item = await repeating();
    final s = (await seriesRepo.get('s1'))!;
    await series.changeRule(
      s.copyWith(freq: RepeatFrequency.weekly, weekdays: {DateTime.friday}),
    );
    final moved = (await items.getItem(item.id))!;
    expect(moved.doDate, day(23));
    expect(moved.occurrenceDate, day(23));
    expect(moved.doTime, 8 * 60);
  });

  test('"this and future" updates the template only', () async {
    final item = await repeating();
    final renamed = await items.save(item.copyWith(title: 'Water herbs'));
    await series.applyToFuture(renamed);
    await actions.complete(renamed);

    final [next] = await open();
    expect(next.title, 'Water herbs');
  });

  test('stopping keeps the item as an ordinary one', () async {
    final item = await repeating();
    final stopped = await series.stopRepeating(item);
    expect(stopped.seriesId, isNull);
    expect(await seriesRepo.get('s1'), isNull);
    await actions.complete(stopped);
    expect(await seriesRepo.occurrences('s1'), isEmpty);
  });
}
