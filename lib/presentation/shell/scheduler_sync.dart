import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/local_date.dart';

/// Keeps series and notifications in step with the database while the app
/// is open (PRD §8.3, §8.4). The background side is `background.dart`.
///
/// Series advance, and Archive and Trash are tidied, on start, on resume and
/// at local midnight. Notifications and the Today home-screen widget are
/// refreshed after those and after any change to items, reminders, series
/// or settings.
class SchedulerSync extends ConsumerStatefulWidget {
  const SchedulerSync({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SchedulerSync> createState() => _SchedulerSyncState();
}

class _SchedulerSyncState extends ConsumerState<SchedulerSync>
    with WidgetsBindingObserver {
  StreamSubscription<void>? _changes;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final db = ref.read(databaseProvider);
    _changes = db
        .tableUpdates(
          TableUpdateQuery.onAllTables([
            db.items,
            db.reminders,
            db.series,
            db.settings,
          ]),
        )
        .listen((_) => _reconcileSoon());
    ref.listenManual<AsyncValue<LocalDate>>(todayProvider, (previous, next) {
      if (next.value != null && previous?.value != next.value) _advance();
    });
    _advance();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _changes?.cancel();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Covers time-zone changes and midnights that passed in the background.
    if (state == AppLifecycleState.resumed) _advance();
  }

  Future<void> _advance() async {
    await ref.read(seriesActionsProvider).advanceAll();
    await ref.read(lifecycleActionsProvider).tidy();
    await ref.read(dayRecordActionsProvider).recordThrough();
    _reconcileSoon();
    try {
      await ref.read(backupScheduleProvider).runIfDue();
    } on Exception catch (error, stack) {
      // A backup that couldn't be written mustn't stop the app.
      ref.read(errorLogProvider).record(error, stack);
    }
  }

  /// Batches bursts of writes, such as a brain-dump capture, into one pass.
  void _reconcileSoon() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(notificationSchedulerProvider).reconcile();
      ref.read(widgetSyncProvider).refresh();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
