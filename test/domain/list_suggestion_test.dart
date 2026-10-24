import 'package:clearing/domain/enums.dart';
import 'package:clearing/domain/item.dart';
import 'package:clearing/domain/list_suggestion.dart';
import 'package:flutter_test/flutter_test.dart';

Item item(String title, String? listId) => Item(
  id: title,
  title: title,
  status: ItemStatus.done,
  listId: listId,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

void main() {
  test('suggests the list similar things went to', () {
    final history = [
      item('Buy milk', 'errands'),
      item('Milk and bread', 'errands'),
      item('Pay milk bill', 'admin'),
      item('Stamps', 'errands'),
    ];
    expect(suggestList('Get milk', history), 'errands');
  });

  test('needs a clear winner and at least two hits', () {
    expect(suggestList('Buy milk', [item('Milk', 'errands')]), isNull);
    expect(
      suggestList('Milk', [
        item('Milk', 'a'),
        item('Milk run', 'a'),
        item('Milk bill', 'b'),
        item('Milk tea', 'b'),
      ]),
      isNull,
    );
    expect(suggestList('Call the', [item('Call the bank', 'a')]), isNull);
  });
}
