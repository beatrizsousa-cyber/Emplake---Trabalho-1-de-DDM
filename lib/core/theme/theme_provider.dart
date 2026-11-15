import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeSettings {
  final ThemeMode themeMode;
  final Color seedColor;
  final double fontSize;
  final String fontFamily;

  const ThemeSettings({
    this.themeMode = ThemeMode.system,
    this.seedColor = const Color(0xFFD64045), // vermelho retrô
    this.fontSize = 16.0,
    this.fontFamily = 'Nunito',
  });

  ThemeSettings copyWith({
    ThemeMode? themeMode,
    Color? seedColor,
    double? fontSize,
    String? fontFamily,
  }) {
    return ThemeSettings(
      themeMode: themeMode ?? this.themeMode,
      seedColor: seedColor ?? this.seedColor,
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }
}

class ThemeNotifier extends StateNotifier<ThemeSettings> {
  ThemeNotifier() : super(const ThemeSettings());

  void updateThemeMode(ThemeMode mode) =>
      state = state.copyWith(themeMode: mode);
  void updateSeedColor(Color color) => state = state.copyWith(seedColor: color);
  void updateFontSize(double size) => state = state.copyWith(fontSize: size);
  void updateFontFamily(String family) =>
      state = state.copyWith(fontFamily: family);
}

final themeProvider =
    StateNotifierProvider<ThemeNotifier, ThemeSettings>((ref) {
  return ThemeNotifier();
});
