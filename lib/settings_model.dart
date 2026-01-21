import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsModel extends ChangeNotifier {
  Color _themeColor = Colors.teal;
  String _fontFamily = 'System'; // 'System', 'Noto Sans JP', 'M PLUS Rounded 1c', 'Sawarabi Mincho'

  Color get themeColor => _themeColor;
  String get fontFamily => _fontFamily;

  SettingsModel() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final int? colorValue = prefs.getInt('themeColor');
    final String? font = prefs.getString('fontFamily');

    if (colorValue != null) {
      _themeColor = Color(colorValue);
    }
    if (font != null) {
      _fontFamily = font;
    }
    notifyListeners();
  }

  Future<void> setThemeColor(Color color) async {
    _themeColor = color;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeColor', color.toARGB32());
  }

  Future<void> setFontFamily(String font) async {
    _fontFamily = font;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fontFamily', font);
  }

  // Helper to get TextStyle based on current font setting
  TextStyle getTextStyle({TextStyle? baseStyle}) {
    final style = baseStyle ?? const TextStyle();
    switch (_fontFamily) {
      case 'Noto Sans JP':
        return GoogleFonts.notoSansJp(textStyle: style);
      case 'M PLUS Rounded 1c':
        return GoogleFonts.mPlusRounded1c(textStyle: style);
      case 'Sawarabi Mincho':
        return GoogleFonts.sawarabiMincho(textStyle: style);
      default:
        // System default (Roboto on Android) works well for Japanese too usually
        return style;
    }
  }
}
