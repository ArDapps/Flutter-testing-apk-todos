import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';

class SoundProvider with ChangeNotifier {
  double _volume = 1.0;
  final LocalStorageService _storage = LocalStorageService();

  SoundProvider() {
    _loadVolume();
  }

  double get volume => _volume;

  Future<void> _loadVolume() async {
    _volume = await _storage.getVolume();
    notifyListeners();
  }

  Future<void> setVolume(double volume) async {
    _volume = volume;
    await _storage.saveVolume(volume);
    notifyListeners();
  }
}
