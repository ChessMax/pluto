import 'package:dio/dio.dart';
import 'package:pluto/data/create_course_response.dart';
import 'package:pluto/data/create_section_response.dart';
import 'package:pluto/data/create_unit_response.dart';
import 'package:pluto/data/json.dart';
import 'package:pluto/data/lesson_dto.dart';
import 'package:pluto/data/step_source_dto.dart';
import 'package:pluto/stepik_api/raw_stepik_entity.dart';
import 'package:pluto/stepik_api/stepik_entity.dart';

class RawStepikApi {
  static const url = 'https://stepik.org/api';

  final Dio _client;

  late final RawStepikEntity<RawLessonDto> lesson = .new(this, 'lesson', RawLessonDto.fromJson);
  late final RawStepikEntity<RawStepDto> step = .new(this, 'step', RawStepDto.fromJson);
  late final RawStepikEntity<RawStepSourceDto> stepSource = .new(this, 'step-source', RawStepSourceDto.fromJson);
  late final RawStepikEntity<RawCourseDto> course = .new(this, 'course', RawCourseDto.fromJson);
  late final RawStepikEntity<RawSectionDto> section = .new(this, 'section', RawSectionDto.fromJson);
  late final RawStepikEntity<RawUnitDto> unit = .new(this, 'unit', RawUnitDto.fromJson);

  RawStepikApi(this._client);

  Dio get client => _client;
}

extension type RawCourseDto(JsonObject value) implements JsonObject {
  int get id => value['id'] as int;
  String get title => value['title'] as String;
  List<int> get sections => getList('sections');

  static RawCourseDto fromJson(JsonObject value) => RawCourseDto(value);
}

extension type RawLessonDto(JsonObject value) implements JsonObject {
  int get id => value['id'] as int;
  String get title => value['title'] as String;
  List<int> get steps => getList('steps');

  static RawLessonDto fromJson(JsonObject value) => RawLessonDto(value);
}

extension type RawStepSourceDto(JsonObject value) implements JsonObject {
  int get id => value['id'] as int;

  static RawStepSourceDto fromJson(JsonObject value) => RawStepSourceDto(value);
}

extension type RawStepDto(JsonObject value) implements JsonObject {
  int get id => value['id'] as int;

  static RawStepDto fromJson(JsonObject value) => RawStepDto(value);
}

extension type RawSectionDto(JsonObject value) implements JsonObject {
  int get id => value['id'] as int;
  String get title => value['title'] as String;
  List<int> get units => getList('units');

  static RawSectionDto fromJson(JsonObject value) => RawSectionDto(value);
}

extension type RawUnitDto(JsonObject value) implements JsonObject {
  int get id => value['id'] as int;
  int get lesson => value['lesson'] as int;

  static RawUnitDto fromJson(JsonObject value) => RawUnitDto(value);
}

extension on JsonObject {
  List<int> getList(String name) => (this[name] as List<dynamic>).cast();
}