import 'package:json_annotation/json_annotation.dart';
import 'package:pluto/data/json.dart';
import 'package:pluto/data/step_source_dto.dart';
import 'package:pluto/data/meta_dto.dart';
import 'package:pluto/data/stepik_list_response.dart';

part 'create_step_response.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class StepResponse extends StepikListResponse {
  @JsonKey(name: 'step-sources')
  final List<StepSourceDto> stepSources;

  StepResponse({
    required super.meta,
    required this.stepSources,
  });

  static StepResponse fromJson(JsonObject value) =>
      _$StepResponseFromJson(value);

  JsonObject toJson() => _$StepResponseToJson(this);
}
