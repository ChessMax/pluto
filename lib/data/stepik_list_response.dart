import 'package:json_annotation/json_annotation.dart';
import 'package:pluto/data/meta_dto.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
abstract class StepikListResponse {
  final MetaDto meta;

  StepikListResponse({required this.meta});
}