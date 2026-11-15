import 'package:country_flags/country_flags.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:emplake_da_bia/l10n/app_localizations.dart';

import '../core/providers/locale_provider.dart';
import '../core/theme/retro_theme.dart';
import '../core/widgets/retro_widgets.dart';

/// Nome de quem desenvolveu o trabalho (aparece na tela de login).
const String kAuthors = 'Beatriz Nascimento de Sousa';

/// Tela de login.
///
/// Em telas largas (computador): à esquerda o título, o idioma e o nome de
/// quem desenvolveu; à direita o formulário de login. Assim não precisa rolar.
/// No celular tudo fica numa coluna só.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final p = RetroPalette.of(context);
    final currentLocale = ref.watch(localeProvider);
    final localeNotifier = ref.read(localeProvider.notifier);

    Widget flag({
      required String countryCode,
      required String tooltip,
      required Locale locale,
    }) {
      final selected = currentLocale.languageCode == locale.languageCode;
      return Tooltip(
        message: tooltip,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => localeNotifier.setLocale(locale),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected ? p.accent : p.ink.withValues(alpha: 0.25),
                  width: selected ? 4 : 2,
                ),
                boxShadow: selected
                    ? [BoxShadow(color: p.ink, offset: const Offset(3, 3))]
                    : null,
              ),
              child: Opacity(
                opacity: selected ? 1 : 0.55,
                child: CountryFlag.fromCountryCode(
                  countryCode,
                  theme: const ImageTheme(
                    width: 48,
                    height: 32,
                    shape: RoundedRectangle(6),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Título + bandeirinhas + nome de quem desenvolveu.
    final header = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RetroTitleBar(title: l10n.appTitle),
        Wrap(
          spacing: 16,
          children: [
            flag(
              countryCode: 'BR',
              tooltip: 'Português',
              locale: const Locale('pt'),
            ),
            flag(
              countryCode: 'US',
              tooltip: 'English',
              locale: const Locale('en'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: RetroCard(
            color: p.card,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                Text(
                  l10n.projectTitle,
                  textAlign: TextAlign.center,
                  style: retroDisplay(context, size: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.credits(kAuthors),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14 * p.fontScale,
                    color: p.ink.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    // Formulário do firebase_ui_auth (e-mail/senha e Google).
    final signIn = SignInScreen(
      providers: [
        EmailAuthProvider(),
        GoogleProvider(
          clientId:
              '170845795672-o11n20eroc1e3ds6lhb6vejri8ta5e9q.apps.googleusercontent.com',
        ),
      ],
      // O redirect do GoRouter já cuida da navegação após o login.
      // Aqui só tratamos erros para a usuária não ficar perdida.
      actions: [
        AuthStateChangeAction<AuthFailed>((context, state) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(l10n.authFailed)));
        }),
      ],
    );

    // O firebase_ui_auth ainda usa o Material antigo e pinta o painel de
    // branco. Aqui o tema do formulário fica TRANSPARENTE, para o fundo
    // retrô (papel, raios e bolinhas) aparecer atrás dele.
    final base = Theme.of(context);
    final loginTheme = base.copyWith(
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: base.colorScheme.copyWith(
        surface: Colors.transparent,
        surfaceTint: Colors.transparent,
        surfaceContainerLowest: Colors.transparent,
        surfaceContainerLow: Colors.transparent,
        surfaceContainer: Colors.transparent,
        surfaceContainerHigh: Colors.transparent,
        surfaceContainerHighest: Colors.transparent,
      ),
    );
    final signInThemed = Theme(
      data: loginTheme,
      // ignore: deprecated_member_use
      child: MaterialUiCompatibilityBridge(child: signIn),
    );

    return Scaffold(
      backgroundColor: p.paper,
      body: RetroBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, box) {
              final wide = box.maxWidth >= 820;

              // ── Computador: dados de um lado, login do outro ──
              if (wide) {
                return Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 480),
                            child: header,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: signInThemed,
                        ),
                      ),
                    ),
                  ],
                );
              }

              // ── Celular: tudo em uma coluna ──
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    children: [
                      header,
                      const SizedBox(height: 12),
                      Expanded(child: signInThemed),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
