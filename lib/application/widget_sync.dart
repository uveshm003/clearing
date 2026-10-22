import 'package:meta/meta.dart';

import '../data/item_repository.dart';
import '../domain/item.dart';
import '../domain/local_date.dart';
import '../domain/today_rules.dart';

/// Rows the Today widget has room for; it matches the largest must-do cap.
const widgetRows = 5;

/// What the Today home-screen widget shows (FR-14).
@immutable
class TodayWidgetData {
  const TodayWidgetData({required this.rows, required this.more});

  /// Must-dos, or other Today items when there are none.
  final List<({String id, String title})> rows;

  /// How many more items are on Today than [rows] shows.
  final int more;

  factory TodayWidgetData.from(TodayView view) {
    final items = <Item>[
      ...view.mustDo,
      if (view.mustDo.isEmpty) ...view.alsoToday,
    ];
    final total = view.mustDo.length + view.alsoToday.length;
    final shown = items.take(widgetRows).toList();
    return TodayWidgetData(
      rows: [for (final item in shown) (id: item.id, title: item.title)],
      more: total - shown.length,
    );
  }

  Map<String, Object?> toJson() => {
    'rows': [
      for (final row in rows) {'id': row.id, 'title': row.title},
    ],
    'more': more,
  };
}

/// The home-screen widgets, as the app sees them.
abstract interface class HomeWidgetGateway {
  Future<void> showToday(TodayWidgetData data);
}

/// Used where there are no home-screen widgets, and in tests.
class NoHomeWidgets implements HomeWidgetGateway {
  const NoHomeWidgets();

  @override
  Future<void> showToday(TodayWidgetData data) async {}
}

/// Keeps the Today widget in step with the database.
class WidgetSync {
  WidgetSync(this._items, this._gateway, {required this._now});

  final ItemRepository _items;
  final HomeWidgetGateway _gateway;
  final DateTime Function() _now;

  Future<void> refresh() async {
    final view = buildTodayView(
      await _items.watchOpen().first,
      LocalDate.fromDateTime(_now()),
    );
    await _gateway.showToday(TodayWidgetData.from(view));
  }
}
