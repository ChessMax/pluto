import 'dart:io';

import 'package:pluto/md/md_file.dart';
import 'package:pluto/md/md_parser.dart';
import 'package:pluto/template/lexer/source_view.dart';

MdFile parseMd(String content) {
  final md = const MdParser().parse(SourceView2(content));
  return md;
}

Future<MdFile> parseMdFile(String filePath) async {
  return parseMd(await File(filePath).readAsString());
}