import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/providers.dart';
import 'data/db/database.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(AppDatabase.open())],
      child: const ClearingApp(),
    ),
  );
}
