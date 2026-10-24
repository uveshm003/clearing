import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/glade.dart';
import '../../l10n/l10n.dart';

/// A few paced breaths before the overwhelm reset (§4.11): a circle that
/// grows for four seconds and shrinks for six, three times, then Ready.
/// With animations off it simply says the words. Skippable at any point.
class BreathingOpener extends StatefulWidget {
  const BreathingOpener({super.key, required this.onDone});

  final VoidCallback onDone;

  static const _in = Duration(seconds: 4);
  static const _out = Duration(seconds: 6);
  static const breaths = 3;

  @override
  State<BreathingOpener> createState() => _BreathingOpenerState();
}

class _BreathingOpenerState extends State<BreathingOpener> {
  var _breath = 0;
  var _inhaling = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _schedule();
  }

  void _schedule() {
    _timer = Timer(_inhaling ? BreathingOpener._in : BreathingOpener._out, () {
      if (!mounted) return;
      setState(() {
        if (!_inhaling) _breath++;
        _inhaling = !_inhaling;
      });
      if (_breath < BreathingOpener.breaths) _schedule();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final glade = GladeTokens.of(context);
    final finished = _breath >= BreathingOpener.breaths;
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(context.l10n.breatheTitle, style: theme.textTheme.headlineSmall),
          Expanded(
            child: Center(
              child: AnimatedContainer(
                duration: reduce
                    ? Duration.zero
                    : (_inhaling ? BreathingOpener._in : BreathingOpener._out),
                curve: Curves.easeInOut,
                width: _inhaling && !finished ? 220 : 120,
                height: _inhaling && !finished ? 220 : 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: glade.skyFull,
                  border: Border.all(color: glade.dawn, width: 3),
                ),
                alignment: Alignment.center,
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    finished
                        ? context.l10n.breatheReady
                        : _inhaling
                        ? context.l10n.breatheIn
                        : context.l10n.breatheOut,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ),
            ),
          ),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            children: [
              if (!finished)
                TextButton(
                  onPressed: widget.onDone,
                  child: Text(context.l10n.breatheSkip),
                ),
              FilledButton(
                onPressed: widget.onDone,
                child: Text(context.l10n.breatheReady),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
