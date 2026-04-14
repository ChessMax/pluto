// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_section_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateSectionResponse _$CreateSectionResponseFromJson(
  Map<String, dynamic> json,
) => CreateSectionResponse(
  sections:
      (json['sections'] as List<dynamic>)
          .map((e) => SectionDto.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$CreateSectionResponseToJson(
  CreateSectionResponse instance,
) => <String, dynamic>{'sections': instance.sections};

SectionDto _$SectionDtoFromJson(Map<String, dynamic> json) =>
    SectionDto(id: (json['id'] as num).toInt());

Map<String, dynamic> _$SectionDtoToJson(SectionDto instance) =>
    <String, dynamic>{'id': instance.id};
