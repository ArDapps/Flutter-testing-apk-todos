
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
    // Migration: If user had 2.0, reduce to 1.5 as 2.0 was too large
    if (_fontScale >= 2.0) {
      _fontScale = 1.5;
      await _storage.saveFontSize(1.5);
    }
    notifyListeners();
  }

  Future<void> setFontScale(double scale) async {
    _fontScale = scale;
    await _storage.saveFontSize(scale);
    notifyListeners();
  }
}
