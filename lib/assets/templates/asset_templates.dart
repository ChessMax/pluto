import 'dart:io';

import 'package:path/path.dart';
import 'package:pluto/assets/templates/course_template_asset.dart';
import 'package:pluto/assets/templates/lesson_template_asset.dart';
import 'package:pluto/assets/templates/section_template_asset.dart';
import 'package:pluto/assets/templates/step_template_asset.dart';
import 'package:pluto/assets/templates/unit_template_asset.dart';
import 'package:pluto/template/code_generator.dart';
import 'package:pluto/template/lexer/lexer.dart';
import 'package:pluto/template/node.dart';
import 'package:pluto/template/parser.dart';
import 'package:pluto/template/template.dart';

abstract final class AssetTemplates {
  static final Future<Template> course = _getTemplate(courseTemplateAsset);
  static final Future<Template> section = _getTemplate(sectionTemplateAsset);
  static final Future<Template> unit = _getTemplate(unitTemplateAsset);
  static final Future<Template> lesson = _getTemplate(lessonTemplateAsset);
  static final Future<Template> step = _getTemplate(stepTemplateAsset);

  static Future<Template> _getTemplate(String source) async {
    // final source = await readTextFile(path);
    final tokens = const Lexer().tokenize(source).toList();
    final node = const Parser().parse(tokens);
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

  Future<void> renderToFile(String filePath, dynamic model) async {
    final dir = dirname(filePath);
    Directory(dir).createSync(recursive: true);
    final file = File(filePath);
    final data = await render(model);
    file.writeAsStringSync(data);
  }
}
