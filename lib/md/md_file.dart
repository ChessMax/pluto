import 'package:pluto/domain/step_source.dart';
import 'package:pluto/template/lexer/source_view.dart';

class MdCodeBlock {
  final String? lang;
  final String code;

  MdCodeBlock(this.lang, this.code);
}

class MdFile {
  final dynamic frontMatter;
  final List<Tag> blocks;
  final String content;
  final List<MdCodeBlock> codes;

  const MdFile({
    required this.frontMatter,
    required this.blocks,
    required this.content,
    this.codes = const [],
  });

  String? getBlockContent(String name) {
    for (final block in blocks) {
      if (block.name == name) {
        return block.content;
      }
    }

    return null;
  }
}
