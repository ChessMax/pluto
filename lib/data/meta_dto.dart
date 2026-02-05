import 'package:json_annotation/json_annotation.dart';
import 'package:pluto/data/json.dart';

part 'meta_dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class MetaDto {
  final int page;
  final bool hasNext;
  final bool hasPrevious;

  MetaDto({
    required this.page,
    required this.hasNext,
    required this.hasPrevious,
  });

  static MetaDto fromJson(JsonObject value) =>
      _$MetaDtoFromJson(value);

  JsonObject toJson() => _$MetaDtoToJson(this);
}

