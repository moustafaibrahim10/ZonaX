import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'isDarkMode';
  late Box<bool> _settingsBox;
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  Future<void> init() async {
    try {
      // Initialize Hive with the documents directory
      final appDocDir = await getApplicationDocumentsDirectory();
      Hive.init(appDocDir.path);

      _settingsBox = await Hive.openBox<bool>('appSettings');
      _isDarkMode = _settingsBox.get(_themeKey, defaultValue: true) ?? true;
    } catch (e) {
      debugPrint('Error initializing theme provider: $e');
      _isDarkMode = true;
    }
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    try {
      _isDarkMode = !_isDarkMode;
      await _settingsBox.put(_themeKey, _isDarkMode);
    } catch (e) {
      debugPrint('Error toggling theme: $e');
    }
    notifyListeners();
  }

  Future<void> setDarkMode(bool isDark) async {
    try {
      _isDarkMode = isDark;
      await _settingsBox.put(_themeKey, _isDarkMode);
    } catch (e) {
      debugPrint('Error setting dark mode: $e');
    }
    notifyListeners();
  }
}
