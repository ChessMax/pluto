import 'package:dio/dio.dart';
import 'package:pluto/data/create_course_response.dart';
import 'package:pluto/data/create_section_response.dart';
import 'package:pluto/data/create_unit_response.dart';
import 'package:pluto/data/lesson_dto.dart';
import 'package:pluto/data/step_source_dto.dart';
import 'package:pluto/stepik_api/stepik_entity.dart';

class StepikApi {
  static const url = 'https://stepik.org/api';
  
  late final StepikEntity<LessonDto> lesson = .new(this, 'lesson', LessonDto.fromJson);
  late final StepikEntity<StepSourceDto> stepSource = .new(this, 'step-source', StepSourceDto.fromJson);
  late final StepikEntity<CourseDto> course = .new(this, 'course', CourseDto.fromJson);
  late final StepikEntity<SectionDto> section = .new(this, 'section', SectionDto.fromJson);
  late final StepikEntity<UnitDto> unit = .new(this, 'unit', UnitDto.fromJson);

  final Dio _client;

  StepikApi(this._client);

  Dio get client => _client;
}
