import 'dart:async';
import 'dart:io';
import 'package:connectivity/connectivity.dart';

class ConnectionsCheck {
  ConnectionsCheck._internal();

  bool isOnline = false;
  bool canUseVk = false;

  static final ConnectionsCheck _instance = ConnectionsCheck._internal();

  static ConnectionsCheck get instance => _instance;

  Connectivity connectivity = Connectivity();

  StreamController controller = StreamController<bool>.broadcast();

  Stream<bool> get onChange => controller.stream;

  Future initialise() async {
    ConnectivityResult result = await connectivity.checkConnectivity();
    await _checkStatus(result);
    checkVKConnection(result);
    connectivity.onConnectivityChanged.listen((result) {
      print('Connection changed');
      _checkStatus(result);
    });
  }

  Future _checkStatus(ConnectivityResult result) async {
    if (result == ConnectivityResult.none) {
      isOnline = false;
    } else {
      try {
        final result = await InternetAddress.lookup('google.com')
            .timeout(Duration(seconds: 20));
        isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      } on SocketException catch (_) {
        isOnline = false;
      } on TimeoutException catch (_) {
        isOnline = false;
      }
    }
    controller.add(isOnline);
  }

  Future checkVKConnection(ConnectivityResult result) async {
    if (result != ConnectivityResult.none) {
      try {
        final result = await InternetAddress.lookup('vk.com')
            .timeout(Duration(seconds: 20));
        canUseVk = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      } on SocketException catch (_) {
        canUseVk = false;
      } on TimeoutException catch (_) {
        canUseVk = false;
      }
    }

    print('Can use vk: $canUseVk');
    return canUseVk;
  }

  void dispose() => controller.close();
}
