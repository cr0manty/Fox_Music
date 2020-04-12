import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:connectivity/connectivity.dart';

class ConnectionsCheck with ChangeNotifier {
  ConnectionsCheck._internal();

  bool isOnline = false;

  static final ConnectionsCheck _instance = ConnectionsCheck._internal();

  static ConnectionsCheck get instance => _instance;

  Connectivity connectivity = Connectivity();

  StreamController controller = StreamController.broadcast();

  Stream get myStream => controller.stream;

  void initialise() async {
    ConnectivityResult result = await connectivity.checkConnectivity();
    _checkStatus(result);
    connectivity.onConnectivityChanged.listen((result) {
      _checkStatus(result);
    });
  }

  void _checkStatus(ConnectivityResult result) async {
    if (result == ConnectivityResult.none) {
      isOnline = false;
    } else {
      try {
        final result = await InternetAddress.lookup('3.17.149.189')
            .timeout(Duration(seconds: 45));
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          isOnline = true;
        } else
          isOnline = false;
      } on SocketException catch (_) {
        isOnline = false;
      } on TimeoutException catch (_) {
        isOnline = false;
      }
    }
    notifyListeners();
  }

  void disposeStream() => controller.close();
}
