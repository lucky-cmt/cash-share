import 'dart:async';

/// Contract for checking network connectivity and observing changes.
abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;
}

/// Default implementation with periodic broadcast stream support.
class NetworkInfoImpl implements NetworkInfo {
  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  Timer? _timer;
  bool _lastStatus = true;

  NetworkInfoImpl() {
    // TODO: Wire actual connectivity monitoring (e.g., DNS lookup or connectivity_plus).
  }

  @override
  Future<bool> get isConnected async => _lastStatus;

  @override
  Stream<bool> get onConnectivityChanged => _controller.stream;

  void updateConnectionStatus(bool isConnected) {
    if (_lastStatus != isConnected) {
      _lastStatus = isConnected;
      _controller.add(isConnected);
    }
  }

  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
