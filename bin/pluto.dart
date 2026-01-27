import 'package:dio/dio.dart';
import 'package:pluto/data/client.dart';
import 'package:pluto/pluto.dart' as pluto;

const _stepikApiUrl = 'https://stepik.org';

void main(List<String> arguments) async {
  final stepikDio = Dio(BaseOptions(
    baseUrl: _stepikApiUrl,
    contentType: Headers.jsonContentType,
    responseType: ResponseType.json,
  ));
  final client = Client(stepikDio);
  final result = await client.getToken('clientId', 'clientSecret');
  print(result);
}
