import 'package:dio/dio.dart';
import 'package:pluto/data/create_course_response.dart';
import 'package:pluto/data/create_section_response.dart';
import 'package:pluto/data/create_unit_response.dart';
import 'package:pluto/data/json.dart';
import 'package:pluto/data/lesson_dto.dart';
import 'package:pluto/data/step_dto.dart';
import 'package:pluto/stepik_api/stepik_entity.dart';

class StepikApi {
  static const url = 'https://stepik.org/api';
  
  late final StepikEntity<LessonDto> lessons = .new(this, 'lessons', LessonDto.fromJson);
  late final StepikEntity<StepDto> steps = .new(this, 'step-sources', StepDto.fromJson);
  late final StepikEntity<CourseDto> courses = .new(this, 'courses', CourseDto.fromJson);
  late final StepikEntity<SectionDto> sections = .new(this, 'sections', SectionDto.fromJson);
  late final StepikEntity<UnitDto> units = .new(this, 'units', UnitDto.fromJson);

  final Dio _client;

  StepikApi(this._client);

  Dio get client => _client;
}
