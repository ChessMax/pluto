import 'package:json_annotation/json_annotation.dart';
import 'package:pluto/data/json.dart';

part 'create_unit_response.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class CreateUnitResponse {
  final List<UnitDto> units;

  CreateUnitResponse({
    required this.units,
  });

  static CreateUnitResponse fromJson(JsonObject value) =>
      _$CreateUnitResponseFromJson(value);

  JsonObject toJson() => _$CreateUnitResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class UnitDto {
  final String id;

  UnitDto({
    required this.id,
  });

  static UnitDto fromJson(JsonObject value) =>
      _$UnitDtoFromJson(value);

  JsonObject toJson() => _$UnitDtoToJson(this);
}
