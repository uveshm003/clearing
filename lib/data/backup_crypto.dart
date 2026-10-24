import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Encrypted backups (FR-17b): AES-256-GCM with a key stretched from a
/// passphrase by PBKDF2-SHA256. Pure Dart, so it works the same in the
/// background as in the app, and offline.
///
/// The file is JSON, so it's recognisable, but holds nothing readable
/// without the passphrase.
abstract final class BackupCrypto {
  static const format = 'clearing-backup-encrypted';
  static const _iterations = 210000;

  static final _cipher = AesGcm.with256bits();
  static final _kdf = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: _iterations,
    bits: 256,
  );

  /// Whether [text] is an encrypted backup.
  static bool isEncrypted(String text) {
    try {
      final json = jsonDecode(text);
      return json is Map && json['format'] == format;
    } on FormatException {
      return false;
    }
  }

  static Future<String> encrypt(String plain, String passphrase) async {
    final salt = _cipher.newNonce() + _cipher.newNonce();
    final key = await _kdf.deriveKeyFromPassword(
      password: passphrase,
      nonce: salt,
    );
    final box = await _cipher.encrypt(utf8.encode(plain), secretKey: key);
    return jsonEncode({
      'format': format,
      'version': 1,
      'kdf': 'pbkdf2-sha256',
      'iterations': _iterations,
      'salt': base64Encode(salt),
      'nonce': base64Encode(box.nonce),
      'mac': base64Encode(box.mac.bytes),
      'data': base64Encode(box.cipherText),
    });
  }

  /// Throws [BackupPassphraseException] if [passphrase] is wrong or the file
  /// was changed.
  static Future<String> decrypt(String text, String passphrase) async {
    final json = jsonDecode(text) as Map;
    final kdf = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: json['iterations'] as int? ?? _iterations,
      bits: 256,
    );
    final key = await kdf.deriveKeyFromPassword(
      password: passphrase,
      nonce: base64Decode(json['salt'] as String),
    );
    final box = SecretBox(
      base64Decode(json['data'] as String),
      nonce: base64Decode(json['nonce'] as String),
      mac: Mac(base64Decode(json['mac'] as String)),
    );
    try {
      final plain = await _cipher.decrypt(box, secretKey: key);
      return utf8.decode(Uint8List.fromList(plain));
    } on SecretBoxAuthenticationError {
      throw const BackupPassphraseException();
    }
  }
}

/// The passphrase doesn't open this backup.
class BackupPassphraseException implements Exception {
  const BackupPassphraseException();
}
