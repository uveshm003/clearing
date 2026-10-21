import 'package:clearing/data/db/database.dart';
import 'package:clearing/data/item_repository.dart';
import 'package:clearing/data/mappers.dart';
import 'package:clearing/domain/enums.dart';
import 'package:clearing/domain/item.dart';
import 'package:clearing/domain/local_date.dart';
import 'package:clearing/domain/search_filter.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;
  late ItemRepository items;

  setUp(() {
    db = memoryDatabase();
    items = ItemRepository(db);
  });
  tearDown(() => db.close());

  Future<List<String>> titles(SearchFilter filter) async => [
    for (final item in await items.search(filter)) item.title,
  ];

  group('ftsQuery', () {
    test('matches every word as a prefix', () {
      expect(ftsQuery('pass  ren'), '"pass"* "ren"*');
    });

    test('neutralises FTS syntax and blank input', () {
      expect(ftsQuery('"a" OR b*'), '"a"* "OR"* "b*"*');
      expect(ftsQuery('   '), isNull);
    });
  });

  test('finds by title, notes, done-means and subtasks', () async {
    final a = await items.capture('Renew passport');
    final b = await items.save(
      (await items.capture('Taxes')).copyWith(notes: () => 'passport copy'),
    );
    final c = await items.capture('Bank');
    await items.addSubtask(c.id, 'Bring passport');
    await items.capture('Unrelated');

    expect(
      (await items.search(const SearchFilter(text: 'pass'))).map((i) => i.id),
      unorderedEquals([a.id, b.id, c.id]),
    );
    expect(await titles(const SearchFilter(text: 'renew pass')), [
      'Renew passport',
    ]);
  });

  test('skips Trash but includes done and archived items', () async {
    final done = await items.capture('Paid rent');
    await items.save(done.copyWith(status: ItemStatus.done, archived: true));
    final trashed = await items.capture('Rent draft');
    await items.save(trashed.copyWith(status: ItemStatus.trashed));

    expect(await titles(const SearchFilter(text: 'rent')), ['Paid rent']);
  });

  test('filters by status, list, date range and repeat', () async {
    final lists = await db.select(db.lists).get();
    Future<Item> add(String title, Item Function(Item) change) async =>
        items.save(change(await items.capture(title)));

    await add(
      'Errand',
      (i) => i.copyWith(status: ItemStatus.active, listId: () => lists[1].id),
    );
    await add('Idea', (i) => i.copyWith(status: ItemStatus.someday));
    await add(
      'Dated',
      (i) => i.copyWith(
        status: ItemStatus.active,
        doDate: () => LocalDate(2026, 10, 25),
      ),
    );
    await add(
      'Later',
      (i) => i.copyWith(
        status: ItemStatus.active,
        doDate: () => LocalDate(2026, 12, 1),
      ),
    );

    expect(await titles(const SearchFilter(statuses: {ItemStatus.someday})), [
      'Idea',
    ]);
    expect(await titles(SearchFilter(listId: lists[1].id)), ['Errand']);
    expect(
      await titles(
        SearchFilter(
          from: LocalDate(2026, 10, 20),
          to: LocalDate(2026, 10, 31),
        ),
      ),
      ['Dated'],
    );
    expect(await titles(const SearchFilter(repeating: true)), isEmpty);
    expect(await titles(const SearchFilter(repeating: false)), hasLength(4));
  });

  test('answers in under 200 ms across 5,000 items', () async {
    final now = DateTime(2026, 10, 20);
    const words = ['call', 'pay', 'book', 'renew', 'buy', 'email', 'tidy'];
    const things = ['bank', 'dentist', 'rent', 'passport', 'milk', 'landlord'];
    await db.batch((b) {
      b.insertAll(db.items, [
        for (var i = 0; i < 5000; i++)
          Item(
            id: 'i$i',
            title: '${words[i % words.length]} ${things[i % things.length]} $i',
            notes: i.isEven
                ? 'note about ${things[(i + 1) % things.length]}'
                : null,
            status: ItemStatus.values[i % 5],
            createdAt: now,
            updatedAt: now.add(Duration(seconds: i)),
          ).toCompanion(),
      ]);
    });
    await items.search(const SearchFilter(text: 'warm up'));

    final stopwatch = Stopwatch()..start();
    final results = await items.search(const SearchFilter(text: 'pass'));
    stopwatch.stop();

    expect(results, isNotEmpty);
    expect(stopwatch.elapsedMilliseconds, lessThan(200));
  });
}
