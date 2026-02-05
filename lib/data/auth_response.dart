import 'package:json_annotation/json_annotation.dart';
import 'package:pluto/data/json.dart';

part 'auth_response.g.dart';

@JsonSerializable()
class AuthResponse {
  @JsonKey(name: 'access_token')
  final String accessToken;

  @JsonKey(name: 'expires_in')
  final int expiresIn;

  @JsonKey(name: 'token_type')
  final String tokenType;

  final String scope;

  AuthResponse({
    required this.accessToken,
    required this.expiresIn,
    required this.tokenType,
    required this.scope,
  });

  static AuthResponse fromJson(JsonObject value) =>
      _$AuthResponseFromJson(value);

  JsonObject toJson() => _$AuthResponseToJson(this);
}
