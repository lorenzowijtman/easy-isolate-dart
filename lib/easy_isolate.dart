library easy_isolate;

import 'dart:isolate';

class EasyIsolate<T> {
  Isolate? _isolate;
  bool _running = false;
  bool _paused = false;
  Capability? _capability;

  late SendPort sendPort;
  late ReceivePort receivePort;

  Function(dynamic) messageHandler;

  Function? onDone;

  void Function(T) operation;

  EasyIsolate({
    required this.messageHandler,
    required this.operation,
  }) {
    this.receivePort = ReceivePort();
    this.sendPort = receivePort.sendPort;
  }

  bool get running => _running;

  void pause() {
    if (_isolate != null) {
      _paused
          ? _isolate!.resume(_capability!)
          : _capability = _isolate!.pause();

      _paused = !_paused;
    }
  }

  void start(T params) async {
    if (_running) {
      return;
    }
    _running = true;

    _isolate = await Isolate.spawn(
      operation,
      params,
    );

    receivePort.listen(messageHandler, onDone: () => onDone);
  }

  void stop() {
    if (_isolate != null) {
      receivePort.close();
      _isolate!.kill(priority: Isolate.immediate);
      _isolate = null;
      _running = false;
    }
  }
}

/// Params class to extend upon
abstract class ThreadParams {
  SendPort sendPort;

  ThreadParams({required this.sendPort});
}
