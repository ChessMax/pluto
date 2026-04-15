import 'package:pluto/data/dio_extensions.dart';
import 'package:pluto/data/json.dart';
import 'package:pluto/stepik_api/stepik_api.dart';
import 'package:pluto/stepik_api/stepik_list_response.dart';

class StepikEntity<T> {
  final String _name;
  final StepikApi _api;
  final T Function(JsonObject value) _parse;

  StepikEntity(this._api, this._name, this._parse);

  Future<T?> create(JsonObject value) async {
    final result = await _api.client.postRequest(
      data: value,
      '/api/$_name',
      (value) => _parseListResponse(value, _name, _parse).items.first,
    );
    return result.toNullable();
  }

  Future<List<T>?> fetch({int? page}) async {
    final result = await _api.client.getRequest(
      '/api/$_name',
      (value) => _parseListResponse(value, _name, _parse).items,
      queryParameters: page != null ? {'page': page} : null,
    );
    return result.toNullable();
  }

  Future<List<T>?> fetchByIds(List<int> entityIds) async {
    final result = await _api.client.getRequest(
      '/api/$_name',
          (value) => _parseListResponse(value, _name, _parse).items,
      queryParameters: { 'ids[]': entityIds },
    );
    return result.toNullable();
  }

  Future<T?> fetchById(int entityId) async {
    final result = await _api.client.getRequest(
      '/api/$_name/$entityId',
      (value) => _parseListResponse(value, _name, _parse).items.first,
    );
    return result.toNullable();
  }

  Future<T?> update(int entityId, JsonObject entity) async {
    final result = await _api.client.putRequest(
      data: entity,
      '/api/$_name/$entityId',
      (value) => _parseListResponse(value, _name, _parse).items.first,
    );
    return result.toNullable();
  }

  Future<void> delete(int entityId) async {
    final result = await _api.client.deleteRequest<void>(
      '/api/$_name/$entityId',
      (value) => value,
    );
    return result.toNullable();
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
