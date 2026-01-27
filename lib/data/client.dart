import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:pluto/data/auth_response.dart';
import 'package:pluto/data/dio_extensions.dart';
import 'package:pluto/data/result.dart';


class Client {
  final Dio _dio;

  Client(this._dio);

  Result<AuthResponse> getToken(String clientId, String clientSecret) {
    final data = utf8.fuse(base64).encode('$clientId:$clientSecret');
    return _dio.postRequest(
        '',
        AuthResponse.fromJson,
        queryParameters: {"Authorization": "Basic $data"}
      );
  }


}