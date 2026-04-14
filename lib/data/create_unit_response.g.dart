// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_unit_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateUnitResponse _$CreateUnitResponseFromJson(Map<String, dynamic> json) =>
    CreateUnitResponse(
      units:
          (json['units'] as List<dynamic>)
              .map((e) => UnitDto.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$CreateUnitResponseToJson(CreateUnitResponse instance) =>
    <String, dynamic>{'units': instance.units};

UnitDto _$UnitDtoFromJson(Map<String, dynamic> json) =>
    UnitDto(id: (json['id'] as num).toInt());

Map<String, dynamic> _$UnitDtoToJson(UnitDto instance) => <String, dynamic>{
  'id': instance.id,
};
