import 'dart:io';

import 'package:pluto/template/code_generator.dart';
import 'package:pluto/template/lexer/lexer.dart';
import 'package:pluto/template/node.dart';
import 'package:pluto/template/parser.dart';
import 'package:pluto/template/template.dart';

abstract final class AssetTemplates {

  static const coursePath = 'assets/templates/course.md.template';

  static final Future<Template> course = _getTemplate(coursePath);

  // ---
  // id: @model.id
  // title: @model.title
  // title_en: @model.title_en
  // ---

  static Future<Template> _getTemplate(String path) async {
    final source = await readTextFile(path);
    final node =  const Parser().parse(const Lexer().tokenize(source).toList());
    final code = const CodeGenerator().generate(DocumentNode(node.toList()));
    final template = Template(code);
    return template;
  }

  static Future<String> readTextFile(String path) async {
    final file = File(path);
    final contents = file.readAsString();
    return contents;
  }
}