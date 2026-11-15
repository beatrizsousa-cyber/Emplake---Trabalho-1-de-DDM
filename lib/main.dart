import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/audio/music_service.dart';
import 'core/providers/locale_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/retro_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/utils/preference_service.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const EmplakeApp(),
    ),
  );
}

class EmplakeApp extends ConsumerWidget {
  const EmplakeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final s = ref.watch(themeProvider);
    final currentLocale = ref.watch(localeProvider);

    // Mantém a música viva enquanto o app estiver aberto
    // (ela só toca se o interruptor das Configurações estiver ligado).
    ref.watch(musicProvider);

    ThemeData theme(Brightness b) => buildRetroTheme(
          seed: s.seedColor,
          brightness: b,
          fontFamily: s.fontFamily,
          fontSize: s.fontSize,
        );

    return MaterialApp.router(
      title: 'Emplake',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      locale: currentLocale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
        FirebaseUILocalizations.delegate,
      ],
      // O navegador só libera o som depois de um clique: o primeiro clique
      // da usuária destrava a música, se ela estiver ligada.
      builder: (context, child) => Listener(
        onPointerDown: (_) => ref.read(musicProvider).onUserGesture(),
        // Ponte temporária: o firebase_ui_auth ainda usa o Material antigo.
        // ignore: deprecated_member_use
        child: MaterialUiCompatibilityBridge(child: child!),
      ),
      // Começa com o tema do dispositivo (ThemeMode.system).
      themeMode: s.themeMode,
      theme: theme(Brightness.light),
      darkTheme: theme(Brightness.dark),
    );
  }
}
