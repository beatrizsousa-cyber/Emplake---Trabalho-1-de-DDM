enum GameLevel { facil, intermediario, avancado, dificil }

extension GameLevelExtension on GameLevel {
  /// Nome amigável para exibir na UI.
  String get displayName {
    switch (this) {
      case GameLevel.facil:
        return 'Fácil';
      case GameLevel.intermediario:
        return 'Intermediário';
      case GameLevel.avancado:
        return 'Avançado';
      case GameLevel.dificil:
        return 'Difícil';
    }
  }

  /// Chave estável para salvar no Firestore (evita "GameLevel.facil").
  String get storageKey => name;

  /// Reconstrói o nível a partir da string salva na Firestore.
  static GameLevel fromStorageKey(String? key) {
    return GameLevel.values.firstWhere(
      (l) => l.name == key,
      orElse: () => GameLevel.facil,
    );
  }

  /// Operadores disponíveis no nível.
  List<String> get availableOperators {
    switch (this) {
      case GameLevel.facil:
        return [
          '+',
          '-',
          '*',
          '/',
          '(',
          ')',
          '√',
          '∛',
          '!',
          '**',
          '|',
          '⌊',
          '⌋',
          '⌈',
          '⌉',
        ];
      case GameLevel.intermediario:
        return ['+', '-', '*', '/', '(', ')', '√', '∛', '!', '**', '|'];
      case GameLevel.avancado:
        return ['+', '-', '*', '/', '(', ')', '√', '!', '|'];
      case GameLevel.dificil:
        return ['+', '-', '*', '/', '(', ')', '|'];
    }
  }

  /// Apenas o nível Fácil aceita divisão com resultado não inteiro.
  bool get allowsNonIntegerDivision => this == GameLevel.facil;
}
