import 'dart:isolate';

class Template {
  final String code;

  Template(this.code);

  Future<String> render(dynamic model) async {
    final uri = Uri.dataFromString(code, mimeType: 'application/dart');
    final receivePort = ReceivePort();

    await Isolate.spawnUri(uri, [], [receivePort.sendPort, model]);

    final output = await receivePort.first;
    receivePort.close();

    return output as String;
  }
}
