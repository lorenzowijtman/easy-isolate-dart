##Example

```
class ConnectionPoll {
  bool isConnected = true;
  EasyIsolate<PollParams>? isolate;
  final BuildContext context;

  ConnectionPoll(this.context);

  void start() {
    isolate = EasyIsolate(
      messageHandler: messageHandler,
      operation: pollConnection,
    );

    final params = PollParams(
      sendPort: isolate!.sendPort,
      connected: true,
      timeout: 30,
    );

    isolate?.start.call(params);
  }

  void stop() => isolate?.stop.call();

  void pause() => isolate?.pause.call();

  void resume() => isolate?.pause.call();

  void messageHandler(dynamic message) {
    if (message is bool && !message) {
      showSnackbar(context: context, text: 'Internet connection lost');
    } else if (message is int) {
      isolate?.pause.call();
      Future.delayed(Duration(seconds: message))
          .then((_) => isolate?.pause.call());
    }
  }

  static Future pollConnection(PollParams params) async {
    do {
      try {
        final result = await InternetAddress.lookup('example.com');
        if (result.isEmpty && result[0].rawAddress.isEmpty) {
          params.sendPort.send(false);
        }
        params.sendPort.send(params.timeout);
      } on SocketException catch (_) {
        params.sendPort.send(false);
      }
    } while (true);
  }
}

class PollParams implements ThreadParams {
  @override
  SendPort sendPort;

  bool connected;

  /// Timeout in seconds
  int timeout;

  PollParams({
    required this.sendPort,
    required this.connected,
    required this.timeout,
  });
}

```
