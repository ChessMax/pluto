// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meta_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MetaDto _$MetaDtoFromJson(Map<String, dynamic> json) => MetaDto(
  page: (json['page'] as num).toInt(),
  hasNext: json['has_next'] as bool,
  hasPrevious: json['has_previous'] as bool,
);

Map<String, dynamic> _$MetaDtoToJson(MetaDto instance) => <String, dynamic>{
  'page': instance.page,
  'has_next': instance.hasNext,
  'has_previous': instance.hasPrevious,
};
