library easy_isolate;

import 'dart:isolate';

class EasyIsolate {
  Isolate? _isolate;
  bool _running = false;
  bool _paused = false;
  ReceivePort? _receivePort;
  Capability? _capability;
  SendPort? sendPort;
  ThreadParams? params;

  Function(dynamic) messageHandler;

  Function onDone;

  Function(ThreadParams?) operation;

  EasyIsolate({
    required this.messageHandler,
    required this.onDone,
    required this.operation,
  });

  bool get running => _running;

  set threadParams(ThreadParams params) => this.params = params;

  void pause() {
    if (_isolate != null) {
      _paused
          ? _isolate!.resume(_capability!)
          : _capability = _isolate!.pause();

      _paused = !_paused;
    }
  }

  void start() async {
    if (_running) {
      return;
    }
    _running = true;

    _receivePort ?? ReceivePort();

    if (params == null) {
      sendPort = _receivePort!.sendPort;
      params = ThreadParams(sendPort: _receivePort!.sendPort);
    }

    _isolate = await Isolate.spawn(
      operation,
      params,
    );
    _receivePort!.listen(messageHandler, onDone: () => onDone());
  }

  void stop() {
    if (_isolate != null) {
      _receivePort!.close();
      _isolate!.kill(priority: Isolate.immediate);
      _isolate = null;
      _running = false;
    }
  }
}

/// Params class to extend upon
class ThreadParams {
  final SendPort sendPort;

  ThreadParams({required this.sendPort});
}
