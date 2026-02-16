import 'package:json_annotation/json_annotation.dart';
import 'package:pluto/data/json.dart';

part 'create_section_response.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class CreateSectionResponse {
  final List<SectionDto> sections;

  CreateSectionResponse({
    required this.sections,
  });

  static CreateSectionResponse fromJson(JsonObject value) =>
      _$CreateSectionResponseFromJson(value);

  JsonObject toJson() => _$CreateSectionResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SectionDto {
  final String id;

  SectionDto({
    required this.id,
  });

  static SectionDto fromJson(JsonObject value) =>
      _$SectionDtoFromJson(value);

  JsonObject toJson() => _$SectionDtoToJson(this);
}
