import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('pt'));

  void setLocale(Locale locale) => state = locale;

  void toggleLocale() {
    state =
        state.languageCode == 'pt' ? const Locale('en') : const Locale('pt');
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});
