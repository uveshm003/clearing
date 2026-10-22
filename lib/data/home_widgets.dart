import 'dart:convert';

import 'package:home_widget/home_widget.dart';

import '../application/widget_sync.dart';

/// [HomeWidgetGateway] backed by home_widget. The widgets themselves are
/// native layouts: `TodayWidgetProvider.kt` and `CaptureWidgetProvider.kt`.
class HomeWidgets implements HomeWidgetGateway {
  const HomeWidgets();

  /// Shared with `TodayWidgetProvider.kt`.
  static const todayKey = 'today';

  @override
  Future<void> showToday(TodayWidgetData data) async {
    await HomeWidget.saveWidgetData<String>(
      todayKey,
      jsonEncode(data.toJson()),
    );
    await HomeWidget.updateWidget(androidName: 'TodayWidgetProvider');
  }
}

/// The links widgets open the app with, or ask it to act on (PRD §8.1).
sealed class WidgetLink {
  const WidgetLink();

  static WidgetLink? parse(Uri? uri) {
    if (uri == null || uri.scheme != 'clearing') return null;
    return switch (uri.host) {
      'capture' => const CaptureLink(),
      'today' => const TodayLink(),
      'item' when uri.pathSegments.isNotEmpty => ItemLink(
        uri.pathSegments.first,
      ),
      'complete' when uri.queryParameters['id'] != null => CompleteLink(
        uri.queryParameters['id']!,
      ),
      _ => null,
    };
  }
}

/// clearing://capture
class CaptureLink extends WidgetLink {
  const CaptureLink();
}

/// clearing://today
class TodayLink extends WidgetLink {
  const TodayLink();
}

/// `clearing://item/<id>`
class ItemLink extends WidgetLink {
  const ItemLink(this.id);
  final String id;
}

/// `clearing://complete?id=<id>`, sent by the widget's check mark in the
/// background.
class CompleteLink extends WidgetLink {
  const CompleteLink(this.id);
  final String id;
}
