// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_step_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StepResponse _$StepResponseFromJson(Map<String, dynamic> json) => StepResponse(
  meta: MetaDto.fromJson(json['meta'] as Map<String, dynamic>),
  stepSources: (json['step-sources'] as List<dynamic>)
      .map((e) => StepSourceDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$StepResponseToJson(StepResponse instance) =>
    <String, dynamic>{
      'meta': instance.meta,
      'step-sources': instance.stepSources,
    };
