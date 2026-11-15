import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/preference_service.dart';

// Importações das telas do aplicativo
import 'package:emplake_da_bia/screens/login_screen.dart';
import 'package:emplake_da_bia/screens/shell_screen.dart';
import 'package:emplake_da_bia/screens/game_screen.dart';
import 'package:emplake_da_bia/screens/settings_screen.dart';
import 'package:emplake_da_bia/screens/history_screen.dart';

/// [PONTO 1] - Classe auxiliar para escutar mudanças de autenticação.
///
/// O GoRouter precisa saber quando o usuário loga ou desloga para
/// reavaliar as regras de redirecionamento (redirect). Como o
/// FirebaseAuth usa Streams (fluxos), nós adaptamos esse Stream
/// para um ChangeNotifier, que é o formato que o GoRouter entende.
class _AuthRefresh extends ChangeNotifier {
  late final StreamSubscription<User?> _sub;

  _AuthRefresh(Stream<User?> stream) {
    // Sempre que o estado de autenticação mudar (login/logout),
    // avisamos o GoRouter para ele reavaliar as rotas.
    _sub = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _sub.cancel(); // Cancela a inscrição para evitar vazamento de memória
    super.dispose();
  }
}

/// [PONTO 2] - Provider que cria e gerencia o nosso roteador.
///
/// Usamos um Provider do Riverpod para que o GoRouter seja criado uma
/// única vez (singleton) e possa ser acessado em qualquer lugar do app.
/// Se dependermos de outras coisas (como o PreferenceService), o
/// Riverpod recria o roteador automaticamente quando necessário.
final routerProvider = Provider<GoRouter>((ref) {
  // Pega o serviço de preferências (SharedPreferences) do Riverpod
  final prefService = ref.watch(preferenceServiceProvider);

  // Cria o "escutador" de login para o GoRouter
  final authRefresh = _AuthRefresh(FirebaseAuth.instance.authStateChanges());

  // Garante que o _AuthRefresh seja descartado quando o provider morrer
  ref.onDispose(authRefresh.dispose);

  /// [PONTO 3] - Função que descobre qual foi a última rota salva.
  ///
  /// Se a rota salva estiver vazia ou for a tela de login, retornamos
  /// '/game' como padrão. Isso evita que o app abra na tela de login
  /// caso o usuário já esteja logado.
  String lastRoute() {
    final r = prefService.getLastRoute();
    return (r.isEmpty || r == '/login') ? '/game' : r;
  }

  // Cria o roteador principal
  final router = GoRouter(
    // [PONTO 4] - Rota inicial do app.
    // É calculada UMA VEZ quando o provider é criado, usando o valor
    // salvo no SharedPreferences. Se não tiver nada, vai para /game.
    initialLocation: lastRoute(),

    // Diz ao GoRouter para reavaliar o redirect sempre que o login mudar
    refreshListenable: authRefresh,

    /// [PONTO 5] - Regra de redirecionamento.
    ///
    /// Executada ANTES de cada navegação. Aqui decidimos:
    /// - Se não estiver logado: vai para /login.
    /// - Se estiver logado e tentar abrir /login: volta para a última rota.
    /// - Caso contrário: deixa navegar normalmente.
    ///
    /// IMPORTANTE: O redirect deve ser SÍNCRONO (não pode usar await).
    /// Por isso, a persistência da rota é feita em um listener separado
    /// logo abaixo, e não dentro deste bloco.
    redirect: (context, state) {
      final loggedIn = FirebaseAuth.instance.currentUser != null;
      final loc = state.matchedLocation;

      // Se não está logado e não está na tela de login, redireciona para login
      if (!loggedIn) return loc == '/login' ? null : '/login';

      // Se está logado mas está na tela de login, manda para a última rota
      if (loc == '/login') return lastRoute();

      // Em qualquer outro caso, permite a navegação
      return null;
    },

    // [PONTO 6] - Definição de todas as rotas do aplicativo.
    routes: [
      // Rota de login (fora do ShellScreen, sem BottomNavigationBar)
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      // ShellRoute mantém o BottomNavigationBar visível nas telas internas.
      // O `child` é a tela atual (game, history ou settings).
      ShellRoute(
        builder: (context, state, child) => ShellScreen(child: child),
        routes: [
          GoRoute(
            path: '/game',
            builder: (context, state) => const GameScreen(),
          ),
          GoRoute(
            path: '/history',
            builder: (context, state) => const HistoryScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );

  router.routerDelegate.addListener(() {
    // Pega o caminho atual da navegação (ex: '/game', '/settings')
    final currentPath = router.routerDelegate.currentConfiguration.uri.path;

    // Só salvamos se for uma rota válida (ignora vazio e tela de login)
    if (currentPath.isNotEmpty && currentPath != '/login') {
      prefService.saveLastRoute(currentPath);
    }
  });

  return router;
});
