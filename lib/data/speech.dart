import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// What the recogniser hears, as it goes.
sealed class SpeechEvent {
  const SpeechEvent();
}

/// Words so far; [isFinal] once a pause ends the phrase.
class SpeechWords extends SpeechEvent {
  const SpeechWords(this.text, {required this.isFinal});
  final String text;
  final bool isFinal;
}

/// Listening stopped, after silence or [SpeechGateway.stop].
class SpeechDone extends SpeechEvent {
  const SpeechDone();
}

/// It couldn't listen: no permission, no offline language pack, busy.
class SpeechFailed extends SpeechEvent {
  const SpeechFailed(this.reason);
  final String reason;
}

/// Speech to text on the phone only (FR-01b). Never the cloud: if the phone
/// can't recognise speech offline, [isAvailable] is false and the
/// microphone button doesn't show.
abstract interface class SpeechGateway {
  Future<bool> isAvailable();

  /// Starts listening in [languageTag] (e.g. `en-IN`, `hi-IN`).
  Stream<SpeechEvent> listen(String languageTag);

  Future<void> stop();
}

/// Where there's no on-device recogniser, and in tests.
class NoSpeech implements SpeechGateway {
  const NoSpeech();

  @override
  Future<bool> isAvailable() async => false;

  @override
  Stream<SpeechEvent> listen(String languageTag) => const Stream.empty();

  @override
  Future<void> stop() async {}
}

/// Android's on-device recogniser, through `SpeechChannel.kt`.
class DeviceSpeech implements SpeechGateway {
  const DeviceSpeech();

  static const _methods = MethodChannel('clearing/speech');
  static const _events = EventChannel('clearing/speech/events');

  @override
  Future<bool> isAvailable() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return false;
    }
    try {
      return await _methods.invokeMethod<bool>('isAvailable') ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  @override
  Stream<SpeechEvent> listen(String languageTag) => _events
      .receiveBroadcastStream(languageTag)
      .map<SpeechEvent>((event) {
        final map = event is Map ? event : const {};
        return switch (map['type']) {
          'words' => SpeechWords(
            '${map['text'] ?? ''}',
            isFinal: map['final'] == true,
          ),
          'error' => SpeechFailed('${map['reason'] ?? 'error'}'),
          _ => const SpeechDone(),
        };
      })
      .handleError((Object e) => const SpeechFailed('error'));

  @override
  Future<void> stop() async {
    try {
      await _methods.invokeMethod<void>('stop');
    } on MissingPluginException {
      // Nothing listening.
    }
  }
}
