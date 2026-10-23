import 'dart:convert';
import 'dart:io';

/// Errors the app ran into, kept on the phone only (Clearing has no crash
/// reporting). People can choose to attach the log to feedback, and see
/// every word before it is sent.
///
/// Entries hold the error's type, a trimmed message and the top of the
/// stack, never item contents on purpose. The log keeps the last
/// [maxEntries].
class ErrorLog {
  /// Backed by [file]; in memory only when null (tests, or no storage).
  ErrorLog([this._file]);

  static const maxEntries = 50;
  static const _maxMessage = 300;
  static const _maxFrames = 12;

  final File? _file;
  final _memory = <String>[];

  Future<List<String>> _lines() async {
    final file = _file;
    if (file == null) return [..._memory];
    try {
      return await file.exists() ? await file.readAsLines() : <String>[];
    } on FileSystemException {
      return <String>[];
    }
  }

  Future<void> _write(List<String> lines) async {
    final kept = lines.length > maxEntries
        ? lines.sublist(lines.length - maxEntries)
        : lines;
    final file = _file;
    if (file == null) {
      _memory
        ..clear()
        ..addAll(kept);
      return;
    }
    try {
      await file.parent.create(recursive: true);
      await file.writeAsString(kept.isEmpty ? '' : '${kept.join('\n')}\n');
    } on FileSystemException {
      // Logging must never be the thing that breaks the app.
    }
  }

  Future<void> record(Object error, StackTrace? stack, {DateTime? at}) async {
    final message = '$error';
    final frames = (stack?.toString() ?? '')
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .take(_maxFrames)
        .toList();
    await _write([
      ...await _lines(),
      jsonEncode({
        'at': (at ?? DateTime.now()).toIso8601String(),
        'type': error.runtimeType.toString(),
        'message': message.length > _maxMessage
            ? '${message.substring(0, _maxMessage)}…'
            : message,
        'stack': frames,
      }),
    ]);
  }

  Future<int> count() async => (await _lines()).length;

  Future<void> clear() => _write(const []);

  /// The log as plain text for attaching to feedback.
  Future<String> asText() async {
    final out = StringBuffer();
    for (final line in await _lines()) {
      try {
        final e = jsonDecode(line) as Map<String, Object?>;
        out
          ..writeln('${e['at']}  ${e['type']}: ${e['message']}')
          ..writeAll((e['stack'] as List? ?? const []).map((f) => '    $f\n'));
      } on FormatException {
        continue;
      }
    }
    return out.toString();
  }
}
