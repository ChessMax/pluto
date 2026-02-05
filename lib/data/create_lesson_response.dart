import 'package:json_annotation/json_annotation.dart';
import 'package:pluto/data/json.dart';
import 'package:pluto/data/lesson_dto.dart';
import 'package:pluto/data/meta_dto.dart';
import 'package:pluto/data/stepik_list_response.dart';

part 'create_lesson_response.g.dart';

@JsonSerializable()
class CreateLessonResponse extends StepikListResponse {
  final List<LessonDto> lessons;

  CreateLessonResponse({
    required super.meta,
    required this.lessons,
  });

  static CreateLessonResponse fromJson(JsonObject value) =>
      _$CreateLessonResponseFromJson(value);

  JsonObject toJson() => _$CreateLessonResponseToJson(this);
}

