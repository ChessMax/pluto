import 'package:json_annotation/json_annotation.dart';
import 'package:pluto/data/json.dart';

part 'auth_response.g.dart';

@JsonSerializable()
class AuthResponse {
  final String accessToken;

  AuthResponse({required this.accessToken});

  static AuthResponse fromJson(JsonObject value) =>
      _$AuthResponseFromJson(value);

  JsonObject toJson() => _$AuthResponseToJson(this);
}
