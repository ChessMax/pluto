import 'dart:io';

import 'package:pluto/template/code_generator.dart';
import 'package:pluto/template/lexer/lexer.dart';
import 'package:pluto/template/node.dart';
import 'package:pluto/template/parser.dart';
import 'package:pluto/template/template.dart';

abstract final class AssetTemplates {
  static const coursePath = 'assets/templates/course.md.template';

  static final Future<Template> course = _getTemplate(coursePath);

  static Future<Template> _getTemplate(String path) async {
    final source = await readTextFile(path);
    final tokens = const Lexer().tokenize(source).toList();
    final node =  const Parser().parse(tokens);
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

extension AssetTemplateExtension on Future<Template> {
  Future<String> render(dynamic model) async {
    final template = await this;
    final result = template.render(model);
    return result;
  }
}