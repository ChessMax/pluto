import 'dart:io';

class Env {
  static final stepikClientId = Platform.environment['STEPIK_CLIENT_ID'] ?? '';
  static final stepikClientSecret =
      Platform.environment['STEPIK_CLIENT_SECRET'] ?? '';
}
