import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// The phone's own lock: fingerprint, face, or PIN, pattern or password
/// (FR-26). Nothing about it leaves the phone or is stored by Clearing.
abstract interface class Authenticator {
  /// Whether the phone has a screen lock to check against.
  Future<bool> isAvailable();

  Future<bool> authenticate(String reason);
}

/// In tests, and where there's no lock to use.
class NoAuthenticator implements Authenticator {
  const NoAuthenticator();

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<bool> authenticate(String reason) async => true;
}

class DeviceAuthenticator implements Authenticator {
  DeviceAuthenticator();

  final _auth = LocalAuthentication();

  @override
  Future<bool> isAvailable() async {
    if (kIsWeb) return false;
    try {
      return await _auth.isDeviceSupported();
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        persistAcrossBackgrounding: true,
      );
    } on PlatformException {
      return false;
    } on LocalAuthException {
      return false;
    }
  }
}
