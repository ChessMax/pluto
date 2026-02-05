// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_lesson_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateLessonResponse _$CreateLessonResponseFromJson(
  Map<String, dynamic> json,
) => CreateLessonResponse(
  meta: MetaDto.fromJson(json['meta'] as Map<String, dynamic>),
  lessons:
      (json['lessons'] as List<dynamic>)
          .map((e) => LessonDto.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$CreateLessonResponseToJson(
  CreateLessonResponse instance,
) => <String, dynamic>{'meta': instance.meta, 'lessons': instance.lessons};
