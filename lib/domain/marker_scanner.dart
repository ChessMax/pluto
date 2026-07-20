import 'package:pluto/domain/source_location.dart';

enum MarkerSeverity {
  /// Reported, but never blocks a push (e.g. `TODO`).
  warning,

  /// Reported and aborts a push (e.g. `FIXME`).
  error,
}

/// A kind of inline reminder marker, `[[<keyword>: message]]`.
class MarkerKind {
  final String keyword;
  final MarkerSeverity severity;

  const MarkerKind({required this.keyword, required this.severity});
}

/// Registered marker kinds.
const List<MarkerKind> markerKinds = [
  MarkerKind(keyword: 'TODO', severity: .warning),
];

/// A single marker found in the course source, with a precise location.
class MarkerFinding {
  final MarkerKind kind;
  final String message;
  final SourceLocation location;

  const MarkerFinding({
    required this.kind,
    required this.message,
    required this.location,
  });

  MarkerSeverity get severity => kind.severity;

  @override
  String toString() => '$location: ${kind.keyword}: $message';
}

class MarkerScanner {
  static final RegExp _pattern = RegExp(
    r'\[\[(' + markerKinds.map((k) => k.keyword).join('|') + r'):\s*(.+?)\]\]',
  );
  static final Map<String, MarkerKind> _byKeyword = {
    for (final kind in markerKinds) kind.keyword: kind,
  };

  const MarkerScanner();

  /// Scans [text], attributing findings to [path].
  List<MarkerFinding> scanText(String text, String path) {
    final index = LineColumnIndex(text);
    final findings = <MarkerFinding>[];

    for (final match in _pattern.allMatches(text)) {
      final keyword = match[1];
      final message = match[2];
      final kind = keyword == null ? null : _byKeyword[keyword];

      if (kind == null || message == null) continue;

      findings.add(
        MarkerFinding(
          kind: kind,
          message: message.trim(),
          location: index.locate(path, match.start),
        ),
      );
    }

    return findings;
  }
}
