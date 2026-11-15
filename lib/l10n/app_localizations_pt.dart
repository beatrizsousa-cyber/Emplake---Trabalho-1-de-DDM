// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Emplake';

  @override
  String get loginAppBar => 'Emplake - Entrar';

  @override
  String get projectTitle => 'Trabalho de Engenharia Reversa - Emplake';

  @override
  String credits(String names) {
    return 'Desenvolvido por: $names';
  }

  @override
  String get gameTitle => 'Desafio Emplake';

  @override
  String get level => 'Nível:';

  @override
  String get easy => 'Fácil';

  @override
  String get medium => 'Intermediário';

  @override
  String get advanced => 'Avançado';

  @override
  String get hard => 'Difícil';

  @override
  String get challengeLabel => 'Toque numa casa e escolha os sinais que ligam os números.';

  @override
  String get yourFormula => 'Sua fórmula:';

  @override
  String get formulaHint => 'Escolha os sinais nas casas...';

  @override
  String get latexLabel => 'Renderização LaTeX:';

  @override
  String get undo => 'Desfazer';

  @override
  String get clear => 'Limpar';

  @override
  String get verify => 'Verificar';

  @override
  String get skip => 'Pular este número';

  @override
  String get nextChallenge => 'Próximo número';

  @override
  String get errUseAllDigits => 'Use os 4 dígitos, na ordem.';

  @override
  String get errNeedEquals => 'A expressão precisa conter o sinal de igual (=).';

  @override
  String get errBothSides => 'Monte a expressão nos dois lados do igual (=).';

  @override
  String get errInvalid => 'Expressão inválida.';

  @override
  String get errNonInteger => 'Neste nível não são permitidas divisões com resultado não inteiro!';

  @override
  String get errDivZero => 'Divisão por zero não é permitida.';

  @override
  String get errDomain => 'Operação fora do domínio permitido (raiz negativa, fatorial inválido ou valor grande demais).';

  @override
  String errOperatorNotAllowed(String op) {
    return 'O operador $op não é permitido neste nível.';
  }

  @override
  String notEqual(String left, String right) {
    return 'A igualdade é falsa: $left ≠ $right';
  }

  @override
  String get success => 'Parabéns! Desafio resolvido com sucesso! 🎉';

  @override
  String get saveError => 'Não foi possível salvar seu progresso na nuvem.';

  @override
  String get history => 'Desafios Resolvidos';

  @override
  String get historyError => 'Erro ao carregar o histórico do Firestore.';

  @override
  String get historyEmpty => 'Nenhum desafio resolvido ainda.\nComece a jogar para salvar suas vitórias!';

  @override
  String historyDigits(String digits) {
    return 'Dígitos: $digits';
  }

  @override
  String historyFormula(String formula) {
    return 'Fórmula: $formula';
  }

  @override
  String get settings => 'Configurações';

  @override
  String get appearance => 'Aparência';

  @override
  String get typography => 'Tipografia';

  @override
  String get themeMode => 'Modo do Tema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get seedColor => 'Cor Semente do Tema';

  @override
  String get fontSize => 'Tamanho da Fonte';

  @override
  String get fontFamily => 'Tipo da Fonte';

  @override
  String get soundEnabled => 'Música de Fundo';

  @override
  String get soundSubtitle => 'Desligado por padrão';

  @override
  String get help => 'Ajuda';

  @override
  String get helpTitle => 'Como Jogar o Emplake';

  @override
  String get helpDetails => '1. Escolha o nível.\n2. Você recebe 4 números fixos. Toque numa casa (entre os números) e escolha os sinais no teclado; casa vazia junta os números (1 e 2 viram 12).\n3. Use o sinal = uma única vez e forme uma igualdade verdadeira.\n4. O nível Fácil aceita divisão não inteira. Nos demais, a divisão deve ser exata.\n5. Toque num sinal já colocado para tirá-lo. Use Pular para trocar de número.';

  @override
  String get gotIt => 'Entendi';

  @override
  String historySolvedOn(String date) {
    return 'Resolvido em: $date';
  }

  @override
  String get authFailed => 'Falha ao autenticar. Tente novamente.';

  @override
  String get logout => 'Sair';

  @override
  String get unknownDate => 'data desconhecida';
}
