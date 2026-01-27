import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pluto/data/result.dart';

typedef ResponseParser<T> = T Function(Map<String, dynamic> value);

enum HttpMethod { get, post, put }

extension DioExtensions on Dio {
  Result<T> safeRequest<T>(
    HttpMethod method,
    String path,
    ResponseParser<T> parser, {
    String? url,
    Object? data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await request<T>(
        '${url ?? options.baseUrl}/$path',
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: Options(method: method.name),
      );
      final parsedResponse = parser(response.data as Map<String, dynamic>);
      return right(parsedResponse);
    } on DioException catch (e) {
      return left(e);
    } catch (e) {
      return left(Exception('Request failed'));
    }
  }

  Result<T> getRequest<T>(
    String path,
    ResponseParser<T> parser, {
    String? url,
    Object? data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    return safeRequest(HttpMethod.get, path, parser);
  }

  Result<T> postRequest<T>(
    String path,
    ResponseParser<T> parser, {
    String? url,
    Object? data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    return safeRequest(HttpMethod.post, path, parser);
  }

  Result<T> putRequest<T>(
    String path,
    ResponseParser<T> parser, {
    String? url,
    Object? data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    return safeRequest(HttpMethod.put, path, parser);
  }
}
