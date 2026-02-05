import 'package:dio/dio.dart';
import 'package:pluto/data/client.dart';
import 'package:pluto/env.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

const _stepikApiUrl = 'https://stepik.org';

void main(List<String> arguments) async {
  final stepikDio = Dio(BaseOptions(
    baseUrl: _stepikApiUrl,
    contentType: Headers.formUrlEncodedContentType,
    responseType: ResponseType.json,
  ));
  stepikDio.interceptors.add(
    TalkerDioLogger(
      settings: const TalkerDioLoggerSettings(
        printRequestHeaders: true,
        printResponseHeaders: true,
        printResponseMessage: true,
      ),
    ),
  );
  final client = StepikClient(stepikDio);
  final result = await client.getToken(Env.stepikClientId, Env.stepikClientSecret);
  print(result);
}
