import 'package:dio/dio.dart';
import 'package:pluto/data/client.dart';
import 'package:pluto/stepik_api/raw_stepik_api.dart';
import 'package:pluto/stepik_api/stepik_api.dart';
import 'package:talker_dio_logger/talker_dio_logger_interceptor.dart';
import 'package:talker_dio_logger/talker_dio_logger_settings.dart';

import '../env.dart';
import 'interceptors/bearer_interceptor.dart';

const _stepikApiUrl = 'https://stepik.org';

Future<InitStepikClientResult> initializeStepikClient() async {
  final stepikDio = Dio(
    BaseOptions(
      baseUrl: _stepikApiUrl,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    ),
  );
  stepikDio.interceptors.add(
    TalkerDioLogger(
      settings: const TalkerDioLoggerSettings(
        printRequestHeaders: true,
        // printResponseHeaders: true,
        printResponseMessage: true,
      ),
    ),
  );
  final client = StepikClient(stepikDio);
  final tokenResult = await client.getToken(
    Env.stepikClientId,
    Env.stepikClientSecret,
  );

  final token = tokenResult.toNullable();
  if (token == null) {
    throw 'Failed to get token';
  }

  stepikDio.interceptors.add(BearerInterceptor(token.accessToken));

  final api = StepikApi(stepikDio);
  final rawApi = RawStepikApi(stepikDio);

  return InitStepikClientResult(api, rawApi);
}

class InitStepikClientResult {
  final StepikApi api;
  final RawStepikApi rawApi;

  InitStepikClientResult(this.api, this.rawApi);
}