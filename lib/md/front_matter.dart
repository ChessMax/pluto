import 'package:yaml/yaml.dart';

/// The YAML block between the `---` markers at the top of a source file.
///
/// Rewriting a course file goes through here rather than regenerating it from
/// scratch, so an author's comments, key order and hand-chosen quoting survive
/// a `push` or an `add`. A format names the keys it owns; anything else in the
/// block is the author's and is copied through untouched.
class FrontMatter {
  /// The parsed block, for reading. Keys the file did not declare are absent.
  final Map<String, dynamic> values;

  /// The block as it was written, so [write] can put back what it did not
  /// change. Empty for a file that does not exist yet.
  final List<_Line> _lines;

  const FrontMatter._(this.values, this._lines);

  static const FrontMatter empty = FrontMatter._(<String, dynamic>{}, []);

  /// Passed as a value to [write] to drop a key the file no longer needs.
  /// Distinct from `null`, which writes the key with an empty value.
  static const Object absent = _Absent();

  dynamic operator [](String key) => values[key];

  /// Splits [source] into its front matter and the body that follows.
  ///
  /// A file without front matter yields [empty] and the whole of [source], so
  /// callers need no special case for one.
  static (FrontMatter, String) split(String source) {
    final lines = source.split('\n');
    if (lines.isEmpty || lines.first.trimRight() != '---') {
      return (empty, source);
    }

    final end = lines.indexWhere((line) => line.trimRight() == '---', 1);
    if (end == -1) return (empty, source);

    final block = lines.sublist(1, end);
    final body = lines.sublist(end + 1).join('\n');
    return (FrontMatter._(_parse(block), _read(block)), body);
  }

  static Map<String, dynamic> _parse(List<String> block) {
    final parsed = loadYaml(block.join('\n'));
    return switch (parsed) {
      null => <String, dynamic>{},
      final Map<dynamic, dynamic> map => {
        for (final entry in map.entries) entry.key.toString(): entry.value,
      },
      _ => throw 'Front matter must be a map of key/value pairs',
    };
  }

  /// Records the block's layout: each top-level key with the lines it spans,
  /// and everything else (comments, blank lines) verbatim.
  static List<_Line> _read(List<String> block) {
    final lines = <_Line>[];

    for (final line in block) {
      final match = _keyPattern.firstMatch(line);
      if (match != null) {
        lines.add(_Field(match.group(1)!, [line]));
        continue;
      }

      // An indented line continues the key above it — a nested map such as
      // `config:` — and has to move or vanish along with it.
      if (line.startsWith(' ')) {
        if (lines.lastOrNull case final _Field field) {
          field.lines.add(line);
          continue;
        }
      }

      lines.add(_Raw(line));
    }

    return lines;
  }

  /// The whole block, `---` markers included, with [fields] applied.
  ///
  /// A key whose value is unchanged keeps the line the author wrote, so a
  /// deliberately quoted or spaced value is not reformatted on every write.
  /// Keys absent from [fields] are left alone; pass [absent] to remove one.
  String write(Map<String, Object?> fields) {
    final written = <String>{};
    final out = <String>[];

    for (final line in _lines) {
      switch (line) {
        case _Raw(:final text):
          out.add(text);
        case _Field(:final key, :final lines) when !fields.containsKey(key):
          out.addAll(lines);
        case _Field(:final key, :final lines):
          written.add(key);
          final value = fields[key];
          if (value == absent) continue;
          // Unchanged: keep the author's spelling of it.
          if (_isScalar(value) && values[key] == value) {
            out.addAll(lines);
          } else {
            out.addAll(_serialize(key, value));
          }
      }
    }

    for (final MapEntry(:key, :value) in fields.entries) {
      if (written.contains(key) || value == absent) continue;
      out.addAll(_serialize(key, value));
    }

    return ['---', ...out, '---', ''].join('\n');
  }

  static bool _isScalar(Object? value) =>
      value == null || value is String || value is num || value is bool;

  static List<String> _serialize(String key, Object? value) {
    return switch (value) {
      // An absent id is the common case for a course not yet pushed; `id:`
      // reads back as null and leaves the line ready to fill in.
      null => ['$key:'],
      final String text => ['$key: ${quoteYamlScalar(text)}'],
      num() || bool() => ['$key: $value'],
      final Map<String, String> map when map.isEmpty => const [],
      final Map<String, String> map => [
        '$key:',
        for (final entry in map.entries)
          '  ${entry.key}: ${quoteYamlScalar(entry.value)}',
      ],
      _ => throw 'Cannot write front matter value `$key`: $value',
    };
  }

  static final RegExp _keyPattern = RegExp(r'^([A-Za-z_][A-Za-z0-9_]*)\s*:');
}

/// Quotes [value] only when writing it bare would change what YAML reads back,
/// so a hand-written file keeps its plain style across a rewrite.
///
/// A plain scalar cannot start with an indicator character, contain `: ` or
/// ` #`, or carry outer spaces; single quotes make any of those literal, with
/// `''` escaping a quote of its own.
String quoteYamlScalar(String value) {
  final needsQuotes =
      value.isEmpty ||
      value.trim() != value ||
      value.contains(': ') ||
      value.contains(' #') ||
      value.contains('\n') ||
      value.endsWith(':') ||
      _indicators.hasMatch(value);
  if (!needsQuotes) return value;
  return "'${value.replaceAll("'", "''")}'";
}

final RegExp _indicators = RegExp(r'''^[-?:,\[\]{}#&*!|>'"%@`]''');

sealed class _Line {
  const _Line();
}

/// A comment or blank line, kept exactly as written.
final class _Raw extends _Line {
  final String text;

  const _Raw(this.text);
}

final class _Field extends _Line {
  final String key;
  final List<String> lines;

  _Field(this.key, this.lines);
}

final class _Absent {
  const _Absent();
}
