import 'package:json_annotation/json_annotation.dart';
import 'package:pluto/data/json.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
abstract class PartialDto {
  @JsonKey(includeToJson: false, includeFromJson: false)
  late JsonObject rawJson;

  JsonObject toJson();
}