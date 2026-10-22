import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// A new UUID v7: time-ordered, so ids sort by creation and stay sync-friendly.
String newId() => _uuid.v7();
