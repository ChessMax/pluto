import 'package:pluto/template/lexer/source_view.dart';

class MdFile {
  final dynamic frontMatter;
  final List<Tag> blocks;
  final String content;

  const MdFile({
    required this.frontMatter,
    required this.blocks,
    required this.content,
  });
}
