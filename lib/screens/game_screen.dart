import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:material_ui/material_ui.dart';

import 'package:emplake_da_bia/l10n/app_localizations.dart';
import '../core/providers/game_providers.dart';
import '../core/theme/retro_theme.dart';
import '../core/widgets/retro_widgets.dart';
import '../logic/emplake_evaluator.dart';
import '../models/game_challenge.dart';
import '../models/game_level.dart';

/// Tela do jogo.
///
/// Ideia da interface: os 4 dígitos ficam FIXOS no meio da tela, como cartas
/// de um cartão de abertura de desenho animado. Entre eles (e nas pontas)
/// existem 5 "casas". A jogadora toca numa casa e escolhe os sinais no
/// teclado; os sinais "pousam" naquela casa. Casa vazia entre dois dígitos
/// junta os números (1 e 2 viram 12).
///
/// Em telas largas (computador) o jogo cabe inteiro, em duas colunas:
/// à esquerda o tabuleiro e a fórmula, à direita o teclado e as ações.
/// No celular as duas colunas viram uma só, com rolagem.
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  BoardNotifier get _board => ref.read(boardProvider.notifier);

  void _resetFeedback() {
    ref.read(feedbackProvider.notifier).state = const FeedbackState();
  }

  void _clearAll() {
    _board.clear();
    _resetFeedback();
  }

  void _say(String message, {bool success = false}) {
    ref.read(feedbackProvider.notifier).state =
        FeedbackState(message: message, isSuccess: success);
  }

  Future<void> _skip(GameChallenge challenge) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await saveSkipped(challenge);
    } catch (_) {
      if (!mounted) return;
      return _say(l10n.saveError);
    }
    if (!mounted) return;
    _clearAll();
    ref.invalidate(challengeProvider);
  }

  String _errorText(AppLocalizations l10n, EvalError error) {
    switch (error) {
      case EvalError.invalid:
        return l10n.errInvalid;
      case EvalError.nonIntegerDivision:
        return l10n.errNonInteger;
      case EvalError.divisionByZero:
        return l10n.errDivZero;
      case EvalError.domain:
        return l10n.errDomain;
    }
  }

  Future<void> _verify(GameChallenge challenge) async {
    final l10n = AppLocalizations.of(context)!;
    final board = ref.read(boardProvider);
    final level = ref.read(gameLevelProvider);
    final expression = board.expression(challenge.digits);

    if (!board.hasEquals) return _say(l10n.errNeedEquals);

    final parts = expression.split('=');
    if (parts.length != 2 || parts[0].isEmpty || parts[1].isEmpty) {
      return _say(l10n.errBothSides);
    }

    final left = EmplakeEvaluator.evaluateSide(parts[0], level);
    final right = EmplakeEvaluator.evaluateSide(parts[1], level);
    if (!left.isValid) return _say(_errorText(l10n, left.error!));
    if (!right.isValid) return _say(_errorText(l10n, right.error!));

    if ((left.value! - right.value!).abs() < 1e-9) {
      try {
        await saveSolved(challenge, expression);
      } catch (_) {
        if (!mounted) return;
        return _say(l10n.saveError);
      }
      if (!mounted) return;
      _say(l10n.success, success: true);
      _board.clear(); // os sinais saem das casas (animação de encolher)
      ref.invalidate(challengeProvider);
    } else {
      _say(l10n.notEqual(_fmt(left.value!), _fmt(right.value!)));
    }
  }

  /// 3.0 -> "3"; 2.5 -> "2.5"; 0.333333 -> "0.3333".
  String _fmt(double v) {
    if ((v - v.roundToDouble()).abs() < 1e-9) return v.round().toString();
    return double.parse(v.toStringAsFixed(4)).toString();
  }

  String _levelName(AppLocalizations l10n, GameLevel level) {
    switch (level) {
      case GameLevel.facil:
        return l10n.easy;
      case GameLevel.intermediario:
        return l10n.medium;
      case GameLevel.avancado:
        return l10n.advanced;
      case GameLevel.dificil:
        return l10n.hard;
    }
  }

  Widget _label(BuildContext context, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 22),
        const SizedBox(width: 8),
        Flexible(
          child: Text(text.toUpperCase(),
              overflow: TextOverflow.ellipsis,
              style: retroDisplay(context, size: 17)),
        ),
      ],
    );
  }

  // ───────────────────────── blocos da tela ─────────────────────────

  Widget _levelsRow(AppLocalizations l10n, RetroPalette p, GameLevel level) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: GameLevel.values.map((l) {
        final selected = l == level;
        return RetroButton(
          onPressed: () {
            ref.read(gameLevelProvider.notifier).state = l;
            _clearAll();
          },
          color: selected ? p.accent : p.card,
          foreground: selected ? p.onAccent : p.ink,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(_levelName(l10n, l).toUpperCase(),
              style: retroDisplay(context, size: 15)),
        );
      }).toList(),
    );
  }

  Widget _boardBlock(AppLocalizations l10n, RetroPalette p,
      GameChallenge challenge, BoardState board) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BoardStrip(
          digits: challenge.digits,
          board: board,
          onSelect: _board.select,
          onRemove: _board.removeAt,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.challengeLabel,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13 * p.fontScale,
            color: p.ink.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _formulaCard(AppLocalizations l10n, RetroPalette p, BoardState board,
      String expression, String latex) {
    return RetroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.yourFormula.toUpperCase(),
              style: retroDisplay(context,
                  size: 13, color: p.accent, letterSpacing: 1.5)),
          const SizedBox(height: 6),
          Text(
            board.isEmpty ? l10n.formulaHint : expression,
            style: retroSymbol(context, size: 26).copyWith(
              color: board.isEmpty ? p.ink.withValues(alpha: 0.45) : p.ink,
            ),
          ),
          const SizedBox(height: 12),
          Container(height: 3, color: p.ink),
          const SizedBox(height: 12),
          Text(l10n.latexLabel.toUpperCase(),
              style: retroDisplay(context,
                  size: 13, color: p.accent, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          latex.isEmpty
              ? const Text('---')
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Math.tex(
                    latex,
                    textStyle:
                        TextStyle(fontSize: 28 * p.fontScale, color: p.ink),
                    onErrorFallback: (_) => Text(expression),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _feedbackBlock(RetroPalette p, FeedbackState feedback) {
    final theme = Theme.of(context);
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      alignment: Alignment.topCenter,
      child: feedback.message.isEmpty
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TweenAnimationBuilder<double>(
                key: ValueKey(feedback),
                tween: Tween(begin: 0.85, end: 1.0),
                duration: const Duration(milliseconds: 400),
                curve: Curves.elasticOut,
                builder: (context, v, child) =>
                    Transform.scale(scale: v, child: child),
                child: RetroCard(
                  color: feedback.isSuccess ? p.gold : theme.colorScheme.error,
                  child: Text(
                    feedback.message,
                    textAlign: TextAlign.center,
                    style: retroDisplay(
                      context,
                      size: 18,
                      letterSpacing: 0.5,
                      color: feedback.isSuccess
                          ? const Color(0xFF1B1B1B)
                          : theme.colorScheme.onError,
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _keyboard(RetroPalette p, GameLevel level, BoardState board) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        RetroButton(
          width: 58,
          height: 58,
          padding: EdgeInsets.zero,
          color: p.accent,
          foreground: p.onAccent,
          // O "=" só pode aparecer uma vez.
          onPressed: board.hasEquals ? null : () => _board.add('='),
          child: Text('=', style: retroSymbol(context, size: 26)),
        ),
        ...level.availableOperators.map(
          (op) => RetroButton(
            width: 58,
            height: 58,
            padding: EdgeInsets.zero,
            onPressed: () => _board.add(op),
            child: Text(op, style: retroSymbol(context, size: 24)),
          ),
        ),
      ],
    );
  }

  Widget _actions(AppLocalizations l10n, RetroPalette p,
      GameChallenge challenge, BoardState board) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: RetroButton(
                onPressed: board.history.isEmpty ? null : _board.undo,
                color: p.paperDeep,
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: _label(context, Icons.undo_rounded, l10n.undo),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RetroButton(
                onPressed: _clearAll,
                color: p.paperDeep,
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: _label(context, Icons.refresh_rounded, l10n.clear),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RetroButton(
                onPressed: () => _verify(challenge),
                color: p.accent,
                foreground: p.onAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: _label(context, Icons.check_rounded, l10n.verify),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        RetroButton(
          onPressed: () => _skip(challenge),
          color: p.card,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: _label(context, Icons.skip_next_rounded, l10n.skip),
        ),
      ],
    );
  }

  // ───────────────────────────── build ─────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = RetroPalette.of(context);

    final level = ref.watch(gameLevelProvider);
    final board = ref.watch(boardProvider);
    final feedback = ref.watch(feedbackProvider);
    final challengeAsync = ref.watch(challengeProvider);

    return RetroScaffold(
      title: l10n.gameTitle,
      maxWidth: 1180,
      child: challengeAsync.when(
        loading: () => Center(
          child: SpinKitFadingCube(color: p.accent, size: 50),
        ),
        error: (e, _) => Center(
          child: RetroCard(child: Text('$e')),
        ),
        data: (challenge) {
          final expression = board.expression(challenge.digits);
          final latex = EmplakeEvaluator.toLaTeX(expression);

          final levels = _levelsRow(l10n, p, level);
          final boardBlock = _boardBlock(l10n, p, challenge, board);
          final formula = _formulaCard(l10n, p, board, expression, latex);
          final feedbackBlock = _feedbackBlock(p, feedback);
          final keyboard = _keyboard(p, level, board);
          final actions = _actions(l10n, p, challenge, board);

          return LayoutBuilder(
            builder: (context, box) {
              final wide = box.maxWidth >= 900;

              // ── Computador: duas colunas, tudo à vista ──
              if (wide) {
                // O conteúdo fica centralizado na vertical: sobra espaço
                // igual em cima e embaixo. Se a janela for baixa, rola.
                const vPad = 16.0;
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, vPad, 24, vPad),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: box.maxHeight > vPad * 2
                          ? box.maxHeight - vPad * 2
                          : 0,
                    ),
                    child: Center(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 11,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                levels,
                                const SizedBox(height: 16),
                                boardBlock,
                                const SizedBox(height: 16),
                                formula,
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 9,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                feedbackBlock,
                                keyboard,
                                const SizedBox(height: 22),
                                actions,
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              // ── Celular: uma coluna com rolagem ──
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    levels,
                    const SizedBox(height: 22),
                    boardBlock,
                    const SizedBox(height: 18),
                    formula,
                    const SizedBox(height: 20),
                    feedbackBlock,
                    keyboard,
                    const SizedBox(height: 28),
                    actions,
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Faixa com os 4 dígitos fixos e as 5 casas para os sinais
// ─────────────────────────────────────────────────────────────
class _BoardStrip extends StatelessWidget {
  const _BoardStrip({
    required this.digits,
    required this.board,
    required this.onSelect,
    required this.onRemove,
  });

  final List<int> digits;
  final BoardState board;
  final void Function(int slot) onSelect;
  final void Function(int slot, int index) onRemove;

  static const _tilts = [-0.05, 0.035, -0.025, 0.05];

  @override
  Widget build(BuildContext context) {
    final p = RetroPalette.of(context);

    return RetroCard(
      color: p.paperDeep,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: LayoutBuilder(
        builder: (context, box) {
          final compact = box.maxWidth < 520;
          final digitW = compact ? 54.0 : 72.0;
          final digitH = compact ? 74.0 : 92.0;
          final slotMin = compact ? 30.0 : 44.0;

          final children = <Widget>[];
          for (var i = 0; i < BoardState.slotCount; i++) {
            children.add(_Slot(
              tokens: board.slots[i],
              active: board.active == i,
              minWidth: slotMin,
              height: digitH,
              onTap: () => onSelect(i),
              onRemove: (index) => onRemove(i, index),
            ));
            if (i < digits.length) {
              children.add(
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Transform.rotate(
                    angle: _tilts[i % _tilts.length],
                    child: SizedBox(
                      width: digitW,
                      height: digitH,
                      child: RetroCard(
                        padding: EdgeInsets.zero,
                        child: Center(
                          child: Text('${digits[i]}',
                              style: retroDisplay(context,
                                  size: compact ? 34 : 44)),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
          }

          // FittedBox: se os sinais crescerem, a faixa encolhe em vez de estourar.
          return FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: children,
            ),
          );
        },
      ),
    );
  }
}

/// Uma casa onde os sinais pousam. Tocar na casa a seleciona;
/// tocar num sinal dentro dela o remove.
class _Slot extends StatelessWidget {
  const _Slot({
    required this.tokens,
    required this.active,
    required this.minWidth,
    required this.height,
    required this.onTap,
    required this.onRemove,
  });

  final List<String> tokens;
  final bool active;
  final double minWidth;
  final double height;
  final VoidCallback onTap;
  final void Function(int index) onRemove;

  @override
  Widget build(BuildContext context) {
    final p = RetroPalette.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: BoxConstraints(minWidth: minWidth, minHeight: height),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: BoxDecoration(
            color:
                active ? p.accent.withValues(alpha: 0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active ? p.accent : p.ink.withValues(alpha: 0.30),
              width: active ? 3 : 2,
            ),
          ),
          child: Center(
            child: tokens.isEmpty
                ? Icon(Icons.add_rounded,
                    size: 18, color: p.ink.withValues(alpha: 0.35))
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < tokens.length; i++)
                        _Token(
                          key: ValueKey('$i-${tokens[i]}'),
                          text: tokens[i],
                          onTap: () => onRemove(i),
                        ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Sinal dentro de uma casa: aparece com um pulinho elástico.
class _Token extends StatelessWidget {
  const _Token({super.key, required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = RetroPalette.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 350),
      curve: Curves.elasticOut,
      builder: (context, v, child) => Transform.scale(scale: v, child: child),
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Text(text,
              style: retroSymbol(context, size: 28).copyWith(color: p.accent)),
        ),
      ),
    );
  }
}
