/// A position in a source file, in IDE-clickable `path:line:column` form.
class SourceLocation {
  final String path;
  final int line;
  final int column;

  const SourceLocation({
    required this.path,
    required this.line,
    required this.column,
  });

  @override
  String toString() => '$path:$line:$column';

  @override
  bool operator ==(Object other) =>
      other is SourceLocation &&
      other.path == path &&
      other.line == line &&
      other.column == column;

  @override
  int get hashCode => Object.hash(path, line, column);
}

/// Maps a character offset within a piece of source text to a [SourceLocation].
///
/// Precomputes line starts once so many lookups over the same text (e.g. every
/// marker or validation finding in a file) are each a binary search. Reusable
/// for any finding that knows an offset into a known file.
class LineColumnIndex {
  final List<int> _lineStarts;

  LineColumnIndex(String text) : _lineStarts = _computeLineStarts(text);

  static List<int> _computeLineStarts(String text) {
    final starts = <int>[0];
    for (var i = 0; i < text.length; ++i) {
      // Only '\n' starts a new line; a trailing '\r' stays in the previous
      // line's content and never begins a marker, so column math is unaffected.
      if (text.codeUnitAt(i) == 0x0A) starts.add(i + 1);
    }
    return starts;
  }

  // TODO: we shouldn't use custom binary search. If we really need it we should use collection package for it or some other package.
  SourceLocation locate(String path, int offset) {
    var lo = 0;
    var hi = _lineStarts.length - 1;
    while (lo < hi) {
      final mid = (lo + hi + 1) >> 1;
      if (_lineStarts[mid] <= offset) {
        lo = mid;
      } else {
        hi = mid - 1;
      }
    }
    return SourceLocation(
      path: path,
      line: lo + 1,
      column: offset - _lineStarts[lo] + 1,
    );
  }
}
