import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/glade.dart';
import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../widgets/clearing_art.dart';

/// The app lock (FR-26): with it on, Clearing asks for the phone's own lock
/// after being away for the chosen time. A thought can still be captured
/// without unlocking: write-only, nothing shown.
class LockGate extends ConsumerStatefulWidget {
  const LockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<LockGate> createState() => _LockGateState();
}

class _LockGateState extends ConsumerState<LockGate>
    with WidgetsBindingObserver {
  /// Locked on start when the lock is on.
  bool? _locked;
  DateTime? _left;
  bool _asking = false;
  final _capture = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _capture.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final settings = ref.read(settingsProvider).value;
    if (settings == null || !settings.appLock) return;
    switch (state) {
      case AppLifecycleState.paused || AppLifecycleState.hidden:
        // The system prompt itself pauses the app; that isn't leaving.
        if (!_asking) _left ??= DateTime.now();
      case AppLifecycleState.resumed:
        final left = _left;
        _left = null;
        if (left != null &&
            DateTime.now().difference(left).inMinutes >=
                settings.lockAfterMinutes) {
          setState(() => _locked = true);
          _unlock();
        }
      default:
        break;
    }
  }

  Future<void> _unlock() async {
    if (_asking) return;
    _asking = true;
    final reason = lookupReason();
    final ok = await ref.read(authenticatorProvider).authenticate(reason);
    _asking = false;
    if (ok && mounted) setState(() => _locked = false);
  }

  String lookupReason() => context.l10n.lockReason;

  Future<void> _saveCapture() async {
    final text = _capture.text;
    if (text.trim().isEmpty) return;
    await ref.read(itemActionsProvider).capture(text);
    _capture.clear();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider).value;
    final on = settings?.appLock ?? false;
    if (settings != null && _locked == null) {
      _locked = on;
      if (on) WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
    }
    final locked = on && (_locked ?? false);
    final theme = Theme.of(context);
    return Stack(
      children: [
        // Hidden from screen readers and taps while locked.
        ExcludeSemantics(
          excluding: locked,
          child: IgnorePointer(ignoring: locked, child: widget.child),
        ),
        if (locked)
          Positioned.fill(
            child: Material(
              color: theme.colorScheme.surface,
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(GladeSpace.xxl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const ClearingArt(ClearingScene.path),
                        const SizedBox(height: GladeSpace.xl),
                        Text(
                          context.l10n.lockTitle,
                          style: theme.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: GladeSpace.lg),
                        FilledButton.icon(
                          icon: const Icon(Icons.lock_open),
                          label: Text(context.l10n.lockUnlock),
                          onPressed: _unlock,
                        ),
                        const SizedBox(height: GladeSpace.xxl),
                        TextField(
                          controller: _capture,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            labelText: context.l10n.lockCapture,
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.arrow_upward),
                              tooltip: context.l10n.commonSave,
                              onPressed: _saveCapture,
                            ),
                          ),
                          onSubmitted: (_) => _saveCapture(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
