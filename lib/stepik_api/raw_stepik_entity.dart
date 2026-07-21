import 'package:dio/dio.dart';
import 'package:pluto/data/dio_extensions.dart';
import 'package:pluto/data/json.dart';
import 'package:pluto/stepik_api/raw_stepik_api.dart';
import 'package:pluto/stepik_api/stepik_api.dart';
import 'package:pluto/stepik_api/stepik_list_response.dart';

class RawStepikEntity<T> {
  final String _name;
  final String _pluralName;
  final RawStepikApi _api;
  final T Function(JsonObject value) _parse;

  RawStepikEntity(this._api, String name, this._parse)
    : _name = name,
      _pluralName = '${name}s';

  Future<T?> create(JsonObject value) async {
    final result = await _api.client.postRequest(
      data: {_name: value},
      '/api/$_pluralName',
      (value) => _parseListResponse(value, _pluralName, _parse).items.first,
    );
    return result.toNullable();
  }

  Future<List<T>?> fetch({int? page}) async {
    final result = await _api.client.getRequest(
      '/api/$_pluralName',
      (value) => _parseListResponse(value, _pluralName, _parse).items,
      queryParameters: page != null ? {'page': page} : null,
    );
    return result.toNullable();
  }

  Future<List<T>?> fetchByIds(List<int> entityIds) async {
    final result = await _api.client.getRequest(
      '/api/$_pluralName',
      (value) => _parseListResponse(value, _pluralName, _parse).items,
      queryParameters: {'ids[]': entityIds},
    );
    return result.toNullable();
  }

  // Future<List<T>?> fetchAllByIds(List<int> entityIds) async {
  //   // TODO
  // }

  Future<T?> fetchById(int entityId) async {
    final result = await _api.client.getRequest(
      '/api/$_pluralName/$entityId',
      (value) => _parseListResponse(value, _pluralName, _parse).items.first,
    );
    return result.toNullable();
  }

  Future<T?> update(int entityId, JsonObject entity) async {
    final result = await _api.client.putRequest(
      data: {_name: entity},
      '/api/$_pluralName/$entityId',
      (value) => _parseListResponse(value, _pluralName, _parse).items.first,
    );
    return result.toNullable();
  }

  /// Deleting is idempotent: Stepik cascades deletions (removing a lesson also
  /// removes its units), so an entity may already be gone by the time we get
  /// to it. A 404 means the desired end state already holds.
  Future<void> delete(int entityId) async {
    try {
      final result = await _api.client.deleteRequest<void>(
        '/api/$_pluralName/$entityId',
        (value) => value,
      );
      return result.toNullable();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return;
      rethrow;
    }
  }

  GStepikListResponse<T> _parseListResponse(
    JsonObject value,
    String fieldName,
    T Function(JsonObject value) parse,
  ) {
    final list = value[fieldName] as List<dynamic>;
    final result = GStepikListResponse(
      items: list.cast<JsonObject>().map(parse).toList(),
    );
    return result;
  }
}
