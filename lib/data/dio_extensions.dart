import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pluto/data/result.dart';

typedef ResponseParser<T> = T Function(Map<String, dynamic> value);

enum HttpMethod { get, put, post, delete, head, options }

extension DioExtensions on Dio {
  Result<T> safeRequest<T>(
    HttpMethod method,
    String path,
    ResponseParser<T> parser, {
    String? url,
    Object? data,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    String? contentType,
  }) async {
    try {
      final response = await request<dynamic>(
        '${url ?? options.baseUrl}$path',
        data: data,
        queryParameters: queryParameters,
        options: Options(
          method: method.name,
          headers: headers,
          contentType: contentType,
        ),
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
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    String? contentType,
  }) async {
    return safeRequest(
      HttpMethod.get,
      path,
      parser,
      headers: headers,
      contentType: contentType,
    );
  }

  Result<T> postRequest<T>(
    String path,
    ResponseParser<T> parser, {
    String? url,
    Object? data,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    String? contentType,
  }) async {
    return safeRequest(
      HttpMethod.post,
      path,
      parser,
      data: data,
      headers: headers,
      queryParameters: queryParameters,
      contentType: contentType,
    );
  }

  Result<T> putRequest<T>(
    String path,
    ResponseParser<T> parser, {
    String? url,
    Object? data,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    String? contentType,
  }) async {
    return safeRequest(
      HttpMethod.put,
      path,
      parser,
      data: data,
      headers: headers,
      queryParameters: queryParameters,
      contentType: contentType,
    );
  }

  Result<T> deleteRequest<T>(
    String path,
    ResponseParser<T> parser, {
    String? url,
    Object? data,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    String? contentType,
  }) async {
    return safeRequest(
      HttpMethod.delete,
      path,
      parser,
      data: data,
      headers: headers,
      queryParameters: queryParameters,
      contentType: contentType,
    );
  }
}
