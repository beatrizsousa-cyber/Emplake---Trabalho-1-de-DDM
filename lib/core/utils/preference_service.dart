import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
      'O sharedPreferencesProvider precisa ser sobrescrito no main.dart');
});

final preferenceServiceProvider = Provider<PreferenceService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PreferenceService(prefs);
});

class PreferenceService {
  final SharedPreferences _prefs;

  PreferenceService(this._prefs);

  static const String _keyLastRoute = 'last_route';
  static const String _keySound = 'sound_enabled';

  Future<void> saveLastRoute(String route) async {
    await _prefs.setString(_keyLastRoute, route);
  }

  /// Retorna a última rota, ou string vazia se nunca navegou.
  String getLastRoute() {
    return _prefs.getString(_keyLastRoute) ?? '';
  }

  /// Som é opcional: começa DESLIGADO (exigência do enunciado).
  bool getSoundEnabled() => _prefs.getBool(_keySound) ?? false;

  Future<void> saveSoundEnabled(bool value) async {
    await _prefs.setBool(_keySound, value);
  }
}
