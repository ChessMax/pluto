/// A source file the course was read from: its [path] and full raw [content].
///
/// Carries the raw file text (front matter included) so findings can be located
/// by exact line/column against the real file, and so scanning is limited to
/// the files the course actually read.
class SourceFile {
  final String path;
  final String content;

  const SourceFile({required this.path, required this.content});
}
