
import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';

class FontSizeProvider with ChangeNotifier {
  double _fontScale = 1.0;
  final LocalStorageService _storage = LocalStorageService();

  FontSizeProvider() {
    _loadFontSize();
  }

  double get fontScale => _fontScale;

  Future<void> _loadFontSize() async {
    _fontScale = await _storage.getFontSize();
    notifyListeners();
  }

  Future<void> setFontScale(double scale) async {
    _fontScale = scale;
    await _storage.saveFontSize(scale);
    notifyListeners();
  }
}
