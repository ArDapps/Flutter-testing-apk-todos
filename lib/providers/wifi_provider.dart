import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class WifiProvider with ChangeNotifier {
  String _connectionStatus = 'Unknown';
  String? _wifiName;
  bool _isWifiConnected = false;

  String get connectionStatus => _connectionStatus;
  String? get wifiName => _wifiName;
  bool get isWifiConnected => _isWifiConnected;

  final Connectivity _connectivity = Connectivity();
  final NetworkInfo _networkInfo = NetworkInfo();

  WifiProvider() {
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _initConnectivity() async {
    List<ConnectivityResult> result;
    try {
      result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      print('Couldn\'t check connectivity status: $e');
    }
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> results) async {
    if (results.contains(ConnectivityResult.wifi)) {
      _isWifiConnected = true;
      _connectionStatus = 'Connected to Wi-Fi';
      await _getWifiName();
    } else if (results.contains(ConnectivityResult.mobile)) {
      _isWifiConnected = false;
      _wifiName = null;
      _connectionStatus = 'Connected to Mobile Network';
    } else if (results.contains(ConnectivityResult.none)) {
      _isWifiConnected = false;
      _wifiName = null;
      _connectionStatus = 'Offline';
    } else {
      _isWifiConnected = false;
      _wifiName = null;
      _connectionStatus = results.map((e) => e.toString()).join(', ');
    }
    notifyListeners();
  }

  Future<void> _getWifiName() async {
    try {
      // Request location permission if not granted, needed for SSID on Android
      if (await Permission.location.isGranted || await Permission.location.request().isGranted) {
        _wifiName = await _networkInfo.getWifiName();
        if (_wifiName != null) {
           _wifiName = _wifiName!.replaceAll('"', ''); // Remove quotes if present
        }
      } else {
        _wifiName = 'Unknown (Permission needed)';
      }
    } catch (e) {
      _wifiName = 'Failed to get Wi-Fi Name';
      print('Error getting Wi-Fi name: $e');
    }
    notifyListeners();
  }
  
  Future<void> checkStatus() async {
      await _initConnectivity();
  }
}
