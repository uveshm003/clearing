import 'package:clearing/data/db/database.dart';
import 'package:clearing/data/item_repository.dart';
import 'package:clearing/data/mappers.dart';
import 'package:clearing/data/reminder_repository.dart';
import 'package:clearing/domain/enums.dart';
import 'package:clearing/domain/reminder.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;
  late ItemRepository items;
  late ReminderRepository reminders;

  setUp(() {
    db = memoryDatabase();
    items = ItemRepository(db);
    reminders = ReminderRepository(db);
  });
  tearDown(() => db.close());

  test('an item has at most three reminders', () async {
    final item = await items.capture('Dentist');
    for (final offset in [0, 10, 60]) {
      expect(await reminders.add(item.id, offsetMinutes: offset), isNotNull);
    }
    expect(await reminders.add(item.id, offsetMinutes: 1440), isNull);
    expect(await reminders.forItem(item.id), hasLength(maxRemindersPerItem));
  });

  test('only reminders of open items are scheduled', () async {
    final open = await items.capture('Open');
    final done = await items.capture('Done');
    await reminders.add(open.id, offsetMinutes: 0);
    await reminders.add(done.id, offsetMinutes: 0);
    await items.save(done.copyWith(status: ItemStatus.done));

    final scheduled = await reminders.enabledWithOpenItems();
    expect(scheduled.map((e) => e.$1.id), [open.id]);
  });

  test('snooze is stored and read back', () async {
    final item = await items.capture('Call');
    final r = await reminders.add(item.id, offsetMinutes: 0);
    final until = DateTime(2026, 10, 20, 10, 15);
    await reminders.snooze(r!.id, until);
    expect((await reminders.get(r.id))!.snoozedUntil, until);
  });

  test('weekday masks round-trip', () {
    const days = {DateTime.monday, DateTime.thursday, DateTime.sunday};
    expect(weekdaysToMask(days), 1 | 8 | 64);
    expect(weekdaysFromMask(weekdaysToMask(days)), days);
  });
}
