import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Which chime to play.
enum Chime { clear, review }

/// Small things only the phone can do (`DeviceChannel.kt`): a short chime,
/// silent when the phone is, and keeping the screen on in Focus.
abstract interface class DeviceGateway {
  Future<void> chime(Chime chime);
  Future<void> keepScreenOn(bool on);
}

/// In tests and where there's no Android host.
class NoDevice implements DeviceGateway {
  const NoDevice();

  @override
  Future<void> chime(Chime chime) async {}

  @override
  Future<void> keepScreenOn(bool on) async {}
}

class PhoneDevice implements DeviceGateway {
  const PhoneDevice();

  static const _channel = MethodChannel('clearing/device');

  bool get _supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  Future<void> chime(Chime chime) async {
    if (!_supported) return;
    try {
      await _channel.invokeMethod<void>('chime', chime.name);
    } on MissingPluginException {
      // No Android host.
    }
  }

  @override
  Future<void> keepScreenOn(bool on) async {
    if (!_supported) return;
    try {
      await _channel.invokeMethod<void>('keepScreenOn', on);
    } on MissingPluginException {
      // No Android host.
    }
  }
}
