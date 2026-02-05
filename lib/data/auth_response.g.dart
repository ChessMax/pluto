// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
  accessToken: json['access_token'] as String,
  expiresIn: (json['expires_in'] as num).toInt(),
  tokenType: json['token_type'] as String,
  scope: json['scope'] as String,
);

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'expires_in': instance.expiresIn,
      'token_type': instance.tokenType,
      'scope': instance.scope,
    };
