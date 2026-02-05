import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:pluto/data/auth_response.dart';
import 'package:pluto/data/dio_extensions.dart';
import 'package:pluto/data/result.dart';

class StepikClient {
  final Dio _dio;

  StepikClient(this._dio);

  Result<AuthResponse> getToken(String clientId, String clientSecret) {
    final data = base64Encode(utf8.encode('$clientId:$clientSecret'));
    return _dio.postRequest(
      '/oauth2/token/',
      AuthResponse.fromJson,
      data: {'grant_type': 'client_credentials'},
      headers: {"Authorization": "Basic $data"},
    );
  }
}
