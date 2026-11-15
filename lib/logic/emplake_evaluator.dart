import 'dart:math' as math;
import '../models/game_level.dart';

/// Tipos de erro que o avaliador pode devolver.
/// A tela traduz cada um com o AppLocalizations (nada de texto fixo aqui).
enum EvalError { invalid, nonIntegerDivision, divisionByZero, domain }

class EvalException implements Exception {
  const EvalException(this.error);
  final EvalError error;
}

class EvaluationResult {
  final bool isValid;
  final double? value;
  final EvalError? error;

  const EvaluationResult.success(this.value)
      : isValid = true,
        error = null;

  const EvaluationResult.failure(this.error)
      : isValid = false,
        value = null;
}

class EmplakeEvaluator {
  // ---------------- LaTeX ----------------

  /// Converte a fórmula do jogo em LaTeX, por exemplo:
  /// `√(8+1)=3**1`  ->  `\sqrt{8+1}=3^{1}`
  static String toLaTeX(String expression) {
    if (expression.isEmpty) return '';
    var latex = expression;

    // Expoente: ** vira ^
    latex = latex.replaceAll('**', '^');

    // Raiz quadrada: com parênteses ou com número
    latex = latex.replaceAllMapped(
      RegExp(r'√\(([^()]*)\)'),
      (m) => '\\sqrt{${m[1]}}',
    );
    latex = latex.replaceAllMapped(
      RegExp(r'√(\d+(?:\.\d+)?)'),
      (m) => '\\sqrt{${m[1]}}',
    );

    // Raiz cúbica
    latex = latex.replaceAllMapped(
      RegExp(r'∛\(([^()]*)\)'),
      (m) => '\\sqrt[3]{${m[1]}}',
    );
    latex = latex.replaceAllMapped(
      RegExp(r'∛(\d+(?:\.\d+)?)'),
      (m) => '\\sqrt[3]{${m[1]}}',
    );

    // Piso, teto e módulo
    latex = latex.replaceAllMapped(
      RegExp(r'⌊([^⌋]*)⌋'),
      (m) => '\\lfloor ${m[1]} \\rfloor',
    );
    latex = latex.replaceAllMapped(
      RegExp(r'⌈([^⌉]*)⌉'),
      (m) => '\\lceil ${m[1]} \\rceil',
    );
    latex = latex.replaceAllMapped(
      RegExp(r'\|([^|]*)\|'),
      (m) => '\\left| ${m[1]} \\right|',
    );

    // Expoente: número ou grupo entre parênteses vira ^{...}
    latex = latex.replaceAllMapped(
      RegExp(r'\^\(([^()]*)\)'),
      (m) => '^{${m[1]}}',
    );
    latex = latex.replaceAllMapped(
      RegExp(r'\^(\d+)'),
      (m) => '^{${m[1]}}',
    );

    // Multiplicação e divisão bonitinhas
    latex = latex.replaceAll('*', '\\cdot ');
    latex = latex.replaceAll('/', '\\div ');

    return latex;
  }

  // ---------------- Avaliação ----------------

  /// Avalia um lado da igualdade. Nunca lança: devolve sempre um resultado.
  static EvaluationResult evaluateSide(String expr, GameLevel level) {
    try {
      final clean = expr.replaceAll('**', '^');
      final parser = _Parser(clean, level);
      final result = parser.parseExpression();
      if (result.isNaN || result.isInfinite || result.abs() > 1e15) {
        return const EvaluationResult.failure(EvalError.domain);
      }
      return EvaluationResult.success(result);
    } on EvalException catch (e) {
      return EvaluationResult.failure(e.error);
    } catch (_) {
      return const EvaluationResult.failure(EvalError.invalid);
    }
  }

  static int _factorial(int n) {
    // 20! é o maior fatorial que cabe num int de 64 bits.
    if (n < 0 || n > 20) throw const EvalException(EvalError.domain);
    var r = 1;
    for (var i = 2; i <= n; i++) {
      r *= i;
    }
    return r;
  }
}

/// Parser recursivo descendente. Precedência (da menor para a maior):
///   + -        soma / subtração
///   * /        multiplicação / divisão
///   ^          potência (direita para a esquerda)
///   unários    - + √ ∛ ⌊ ⌋ ⌈ ⌉ | |
///   !          fatorial (pós-fixo)
class _Parser {
  _Parser(this.src, this.level);

  final String src;
  final GameLevel level;
  int pos = 0;

  void _skipSpaces() {
    while (pos < src.length && src[pos].trim().isEmpty) {
      pos++;
    }
  }

  bool _peek(String c) {
    _skipSpaces();
    return pos < src.length && src[pos] == c;
  }

  void _expect(String c) {
    _skipSpaces();
    if (pos >= src.length || src[pos] != c) {
      throw const EvalException(EvalError.invalid);
    }
    pos++;
  }

  double parseExpression() {
    _skipSpaces();
    final v = _parseAddSub();
    _skipSpaces();
    if (pos != src.length) throw const EvalException(EvalError.invalid);
    return v;
  }

  double _parseAddSub() {
    var left = _parseMulDiv();
    while (true) {
      if (_peek('+')) {
        pos++;
        left += _parseMulDiv();
      } else if (_peek('-')) {
        pos++;
        left -= _parseMulDiv();
      } else {
        break;
      }
    }
    return left;
  }

  double _parseMulDiv() {
    var left = _parsePower();
    while (true) {
      if (_peek('*')) {
        pos++;
        left *= _parsePower();
      } else if (_peek('/')) {
        pos++;
        final right = _parsePower();
        if (right == 0) throw const EvalException(EvalError.divisionByZero);
        final q = left / right;
        // Só o nível Fácil aceita divisão com resultado não inteiro.
        if (!level.allowsNonIntegerDivision &&
            (q - q.roundToDouble()).abs() > 1e-9) {
          throw const EvalException(EvalError.nonIntegerDivision);
        }
        left = q;
      } else {
        break;
      }
    }
    return left;
  }

  double _parsePower() {
    final base = _parseUnary();
    if (_peek('^')) {
      pos++;
      final exp = _parsePower();
      final r = math.pow(base, exp).toDouble();
      if (r.isNaN || r.isInfinite) throw const EvalException(EvalError.domain);
      return r;
    }
    return base;
  }

  double _parseUnary() {
    if (_peek('-')) {
      pos++;
      return -_parseUnary();
    }
    if (_peek('+')) {
      pos++;
      return _parseUnary();
    }
    if (_peek('√')) {
      pos++;
      final v = _parseUnary();
      if (v < 0) throw const EvalException(EvalError.domain);
      return math.sqrt(v);
    }
    if (_peek('∛')) {
      pos++;
      return _cbrt(_parseUnary());
    }
    if (_peek('⌊')) {
      pos++;
      final v = _parseAddSub();
      _expect('⌋');
      return v.floorToDouble();
    }
    if (_peek('⌈')) {
      pos++;
      final v = _parseAddSub();
      _expect('⌉');
      return v.ceilToDouble();
    }
    if (_peek('|')) {
      pos++;
      final v = _parseAddSub();
      _expect('|');
      return v.abs();
    }
    return _parsePostfix();
  }

  /// Fatorial: aplicado a um átomo, ex.: 3! ou (2+1)!
  double _parsePostfix() {
    var v = _parseAtom();
    while (_peek('!')) {
      pos++;
      final n = v.round();
      if ((v - n).abs() > 1e-9) throw const EvalException(EvalError.domain);
      v = EmplakeEvaluator._factorial(n).toDouble();
    }
    return v;
  }

  double _parseAtom() {
    if (_peek('(')) {
      pos++;
      final v = _parseAddSub();
      _expect(')');
      return v;
    }
    return _parseNumber();
  }

  double _parseNumber() {
    _skipSpaces();
    final start = pos;
    while (pos < src.length && '0123456789.'.contains(src[pos])) {
      pos++;
    }
    if (pos == start) throw const EvalException(EvalError.invalid);
    final v = double.tryParse(src.substring(start, pos));
    if (v == null) throw const EvalException(EvalError.invalid);
    return v;
  }

  double _cbrt(double x) {
    if (x < 0) return -math.pow(-x, 1 / 3).toDouble();
    return math.pow(x, 1 / 3).toDouble();
  }
}
