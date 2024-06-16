import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isLightTheme => _themeMode == ThemeMode.light;

  Color get textColor => isLightTheme ? Color(0xFF443D2A) : Colors.white;
  Color get iconColor => isLightTheme ? Color(0xFF443D2A) : Colors.white;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
