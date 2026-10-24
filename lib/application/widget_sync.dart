import 'package:flutter/widgets.dart';

import '../data/item_repository.dart';
import '../domain/enums.dart';
import '../domain/item.dart';
import '../domain/local_date.dart';
import '../domain/today_rules.dart';

/// Rows the Today widget has room for; it matches the largest must-do cap.
const widgetRows = 5;

/// What the Today home-screen widget shows (FR-14).
@immutable
class TodayWidgetData {
  const TodayWidgetData({
    required this.rows,
    required this.more,
    this.inbox = 0,
  });

  /// Must-dos, or other Today items when there are none.
  final List<({String id, String title})> rows;

  /// How many more items are on Today than [rows] shows.
  final int more;

  /// Thoughts waiting in the Inbox, shown when there's room.
  final int inbox;

  factory TodayWidgetData.from(TodayView view, {int inbox = 0}) {
    final items = <Item>[
      ...view.mustDo,
      if (view.mustDo.isEmpty) ...view.alsoToday,
    ];
    final total = view.mustDo.length + view.alsoToday.length;
    final shown = items.take(widgetRows).toList();
    return TodayWidgetData(
      rows: [for (final item in shown) (id: item.id, title: item.title)],
      more: total - shown.length,
      inbox: inbox,
    );
  }

  Map<String, Object?> toJson() => {
    'rows': [
      for (final row in rows) {'id': row.id, 'title': row.title},
    ],
    'more': more,
    'inbox': inbox,
  };
}

/// The home-screen widgets, as the app sees them.
abstract interface class HomeWidgetGateway {
  /// The Today widget and the small "next thing" widget.
  Future<void> showToday(TodayWidgetData data);

  /// The Grove widget's picture, painted by the app (§6.3).
  Future<void> showGrove(Widget picture, Size size);
}

/// Used where there are no home-screen widgets, and in tests.
class NoHomeWidgets implements HomeWidgetGateway {
  const NoHomeWidgets();

  @override
  Future<void> showToday(TodayWidgetData data) async {}

  @override
  Future<void> showGrove(Widget picture, Size size) async {}
}

/// Keeps the Today widget in step with the database.
class WidgetSync {
  WidgetSync(this._items, this._gateway, {required this._now});

  final ItemRepository _items;
  final HomeWidgetGateway _gateway;
  final DateTime Function() _now;

  Future<void> refresh() async {
    final open = await _items.watchOpen().first;
    final view = buildTodayView(open, LocalDate.fromDateTime(_now()));
    await _gateway.showToday(
      TodayWidgetData.from(
        view,
        inbox: open.where((i) => i.status == ItemStatus.inbox).length,
      ),
    );
  }
}
