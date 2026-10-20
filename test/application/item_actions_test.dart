import 'package:clearing/application/item_actions.dart';
import 'package:clearing/data/db/database.dart';
import 'package:clearing/data/item_repository.dart';
import 'package:clearing/domain/enums.dart';
import 'package:clearing/domain/item.dart';
import 'package:clearing/domain/local_date.dart';
import 'package:clearing/domain/today_rules.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;
  late ItemRepository repo;
  late ItemActions actions;
  final now = DateTime(2026, 10, 20, 9);
  final today = LocalDate(2026, 10, 20);

  setUp(() {
    db = memoryDatabase(now: () => now);
    repo = ItemRepository(db, now: () => now);
    actions = ItemActions(repo, now: () => now);
  });
  tearDown(() => db.close());

  test('capture saves each non-empty line as its own item', () async {
    final items = await actions.capture('Buy milk\n\n  Call Sam  \n');
    expect(items.map((i) => i.title), ['Buy milk', 'Call Sam']);
    expect(await repo.watchCount(ItemStatus.inbox).first, 2);
  });

  test('capture ignores blank input', () async {
    expect(await actions.capture('   \n '), isEmpty);
  });

  test('capture → plan → complete → undo', () async {
    final [item] = await actions.capture('Pay rent');
    final planned = await actions.planToday(item);
    expect(isOnToday(planned, today), isTrue);

    await actions.complete(planned);
    expect((await repo.getItem(item.id))!.status, ItemStatus.done);

    await actions.undo(planned);
    expect(await repo.getItem(item.id), planned);
  });

  group('must-do cap', () {
    Future<List<Item>> todayItems(int count) async {
      final out = <Item>[];
      for (var i = 0; i < count; i++) {
        final [item] = await actions.capture('item $i');
        out.add(await actions.planToday(item));
      }
      return out;
    }

    test('flags freely below the cap', () async {
      final items = await todayItems(2);
      final open = await repo.watchOpen().first;
      final result = await actions.setMustDo(
        items.first,
        openItems: open,
        cap: 1,
      );
      expect(result, isA<MustDoAllowed>());
      expect((await repo.getItem(items.first.id))!.mustDo, isTrue);
    });

    test('at the cap, asks to swap and changes nothing', () async {
      final items = await todayItems(2);
      await actions.setMustDo(
        items[0],
        openItems: await repo.watchOpen().first,
        cap: 1,
      );
      final result = await actions.setMustDo(
        items[1],
        openItems: await repo.watchOpen().first,
        cap: 1,
      );
      expect(result, isA<MustDoNeedsSwap>());
      expect((await repo.getItem(items[1].id))!.mustDo, isFalse);

      await actions.swapMustDo(
        out: (await repo.getItem(items[0].id))!,
        into: items[1],
      );
      expect((await repo.getItem(items[0].id))!.mustDo, isFalse);
      expect((await repo.getItem(items[1].id))!.mustDo, isTrue);
    });

    test('items not on Today are not limited by the cap', () async {
      final [first] = await todayItems(1);
      await actions.setMustDo(
        first,
        openItems: await repo.watchOpen().first,
        cap: 1,
      );
      final [later] = await actions.capture('later');
      final planned = await actions.planOnDate(later, today.addDays(2));
      final result = await actions.setMustDo(
        planned,
        openItems: await repo.watchOpen().first,
        cap: 1,
      );
      expect(result, isA<MustDoAllowed>());
    });
  });
}
