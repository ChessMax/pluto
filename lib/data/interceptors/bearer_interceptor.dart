import 'package:dio/dio.dart';

class BearerInterceptor extends Interceptor {
  final String accessToken;

  BearerInterceptor(this.accessToken);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Authorization'] = 'Bearer $accessToken';

    handler.next(options);
  }
}
