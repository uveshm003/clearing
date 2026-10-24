import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:home_widget/home_widget.dart';

import '../application/widget_sync.dart';

/// [HomeWidgetGateway] backed by home_widget. The widgets themselves are
/// native layouts: `TodayWidgetProvider.kt` and `CaptureWidgetProvider.kt`.
class HomeWidgets implements HomeWidgetGateway {
  const HomeWidgets();

  /// Shared with `TodayWidgetProvider.kt` and `NextWidgetProvider.kt`.
  static const todayKey = 'today';

  /// Shared with `GroveWidgetProvider.kt`: the path of the painted Grove.
  static const groveKey = 'grove';

  @override
  Future<void> showToday(TodayWidgetData data) async {
    await HomeWidget.saveWidgetData<String>(
      todayKey,
      jsonEncode(data.toJson()),
    );
    await HomeWidget.updateWidget(androidName: 'TodayWidgetProvider');
    await HomeWidget.updateWidget(androidName: 'NextWidgetProvider');
  }

  @override
  Future<void> showGrove(Widget picture, Size size) async {
    await HomeWidget.renderFlutterWidget(
      picture,
      key: groveKey,
      logicalSize: size,
    );
    await HomeWidget.updateWidget(androidName: 'GroveWidgetProvider');
  }
}

/// The links widgets open the app with, or ask it to act on (PRD §8.1).
sealed class WidgetLink {
  const WidgetLink();

  static WidgetLink? parse(Uri? uri) {
    if (uri == null || uri.scheme != 'clearing') return null;
    final from = uri.queryParameters['from'];
    return switch (uri.host) {
      'capture' => CaptureLink(
        listen: uri.queryParameters['listen'] == '1',
        fromOutside: from != null,
      ),
      'review' => const ReviewLink(),
      'grove' => const GroveLink(),
      'reset' => const ResetLink(),
      'today' => const TodayLink(),
      'inbox' => const InboxLink(),
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

/// clearing://capture, from the widget, a shortcut or the Quick Settings
/// tile; `?listen=1` starts listening straight away.
class CaptureLink extends WidgetLink {
  const CaptureLink({this.listen = false, this.fromOutside = true});
  final bool listen;

  /// Opened from outside the app (always, except in tests).
  final bool fromOutside;
}

/// clearing://review, from a launcher shortcut.
class ReviewLink extends WidgetLink {
  const ReviewLink();
}

/// clearing://inbox, from the Today widget's inbox line.
class InboxLink extends WidgetLink {
  const InboxLink();
}

/// clearing://grove, from the Grove widget.
class GroveLink extends WidgetLink {
  const GroveLink();
}

/// clearing://reset, from a launcher shortcut.
class ResetLink extends WidgetLink {
  const ResetLink();
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
