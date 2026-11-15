import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import '../theme/retro_theme.dart';

/// Fundo de papel antigo: bolinhas de impressão, raios de sol no alto
/// (como nos cartões de abertura dos desenhos de 1930) e cantos escurecidos.
class RetroBackground extends StatelessWidget {
  const RetroBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = RetroPalette.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: CustomPaint(
            painter: _PaperPainter(
              bg: p.paper,
              ink: p.ink,
              ray: p.accent,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _PaperPainter extends CustomPainter {
  _PaperPainter({required this.bg, required this.ink, required this.ray});
  final Color bg;
  final Color ink;
  final Color ray;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = bg);

    // Raios de sol saindo do topo, bem suaves.
    final center = Offset(size.width / 2, -size.height * 0.05);
    final radius = size.longestSide * 1.6;
    final rayPaint = Paint()..color = ray.withValues(alpha: 0.07);
    const rays = 18;
    for (var i = 0; i < rays; i += 2) {
      final a0 = math.pi * (i / rays);
      final a1 = math.pi * ((i + 1) / rays);
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(center.dx + radius * math.cos(a0),
            center.dy + radius * math.sin(a0))
        ..lineTo(center.dx + radius * math.cos(a1),
            center.dy + radius * math.sin(a1))
        ..close();
      canvas.drawPath(path, rayPaint);
    }

    // Bolinhas de impressão (meio-tom).
    final dots = Paint()..color = ink.withValues(alpha: 0.06);
    const step = 22.0;
    var row = 0;
    for (double y = 0; y < size.height; y += step) {
      final shift = row.isEven ? 0.0 : step / 2;
      for (double x = shift; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), 2, dots);
      }
      row++;
    }

    // Vinheta: cantos mais escuros, como um filme antigo.
    final vignette = Paint()
      ..shader = RadialGradient(
        radius: 1.05,
        colors: [Colors.transparent, ink.withValues(alpha: 0.18)],
        stops: const [0.65, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, vignette);
  }

  @override
  bool shouldRepaint(_PaperPainter old) =>
      old.bg != bg || old.ink != ink || old.ray != ray;
}

/// Fileira de lâmpadas de marquise de cinema que piscam em revezamento.
class RetroMarquee extends StatefulWidget {
  const RetroMarquee({super.key});

  @override
  State<RetroMarquee> createState() => _RetroMarqueeState();
}

class _RetroMarqueeState extends State<RetroMarquee>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = RetroPalette.of(context);
    return SizedBox(
      height: 16,
      child: LayoutBuilder(
        builder: (context, box) {
          final count = math.max(4, (box.maxWidth / 26).floor());
          return AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) {
              final phase = _ctrl.value < 0.5 ? 0 : 1;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(count, (i) {
                  final lit = (i + phase).isEven;
                  return Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: lit ? p.gold : p.paperDeep,
                      border: Border.all(color: p.ink, width: 2),
                      boxShadow: lit
                          ? [
                              BoxShadow(
                                color: p.gold.withValues(alpha: 0.7),
                                blurRadius: 6,
                              )
                            ]
                          : null,
                    ),
                  );
                }),
              );
            },
          );
        },
      ),
    );
  }
}

/// Cartão com contorno grosso e sombra dura (como um adesivo).
class RetroCard extends StatelessWidget {
  const RetroCard({
    super.key,
    required this.child,
    this.color,
    this.padding = const EdgeInsets.all(16),
    this.radius = 14,
  });

  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final p = RetroPalette.of(context);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? p.card,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: p.ink, width: 3),
        boxShadow: [BoxShadow(color: p.ink, offset: const Offset(5, 5))],
      ),
      child: child,
    );
  }
}

/// Botão que "afunda" quando apertado. Os textos e ícones herdam a cor [foreground].
class RetroButton extends StatefulWidget {
  const RetroButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.color,
    this.foreground,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    this.width,
    this.height,
    this.radius = 12,
    this.tooltip,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Color? color;
  final Color? foreground;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;
  final double radius;
  final String? tooltip;

  @override
  State<RetroButton> createState() => _RetroButtonState();
}

class _RetroButtonState extends State<RetroButton> {
  bool _down = false;

  void _set(bool value) {
    if (_down != value) setState(() => _down = value);
  }

  @override
  Widget build(BuildContext context) {
    final p = RetroPalette.of(context);
    final enabled = widget.onPressed != null;
    final fill = widget.color ?? p.card;
    final fg = widget.foreground ?? p.ink;
    const depth = 4.0;
    final shift = (_down && enabled) ? depth : 0.0;

    Widget button = AnimatedContainer(
      duration: const Duration(milliseconds: 70),
      width: widget.width,
      height: widget.height,
      padding: widget.padding,
      transform: Matrix4.translationValues(shift, shift, 0),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(widget.radius),
        border: Border.all(color: p.ink, width: 3),
        boxShadow: [
          BoxShadow(
            color: p.ink,
            offset: Offset(depth - shift, depth - shift),
          ),
        ],
      ),
      child: Center(
        widthFactor: 1,
        heightFactor: 1,
        child: DefaultTextStyle.merge(
          style: TextStyle(color: fg),
          child: IconTheme.merge(
            data: IconThemeData(color: fg),
            child: widget.child,
          ),
        ),
      ),
    );

    button = Opacity(opacity: enabled ? 1 : 0.45, child: button);
    button = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => _set(true) : null,
      onTapUp: enabled ? (_) => _set(false) : null,
      onTapCancel: enabled ? () => _set(false) : null,
      onTap: widget.onPressed,
      child: button,
    );
    button = MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
      child: button,
    );
    button = Semantics(button: true, enabled: enabled, child: button);
    if (widget.tooltip != null) {
      button = Tooltip(message: widget.tooltip!, child: button);
    }
    return button;
  }
}

/// Faixa de título com estrelas e linha dupla (cartão de abertura de desenho).
class RetroTitleBar extends StatelessWidget {
  const RetroTitleBar({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final p = RetroPalette.of(context);
    final star =
        Icon(Icons.star_rounded, color: p.accent, size: 28 * p.fontScale);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const RetroMarquee(),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              star,
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  title.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: retroDisplay(context, size: 30, shadow: true),
                ),
              ),
              const SizedBox(width: 10),
              star,
            ],
          ),
          const SizedBox(height: 8),
          Container(height: 4, color: p.ink),
          const SizedBox(height: 3),
          Container(height: 1.5, color: p.ink),
        ],
      ),
    );
  }
}

/// Moldura padrão das telas: fundo de papel + título + conteúdo centralizado.
class RetroScaffold extends StatelessWidget {
  const RetroScaffold({
    super.key,
    required this.title,
    required this.child,
    this.maxWidth = 760,
  });

  final String title;
  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final p = RetroPalette.of(context);
    return Scaffold(
      backgroundColor: p.paper,
      body: RetroBackground(
        child: SafeArea(
          child: Column(
            children: [
              RetroTitleBar(title: title),
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: child,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Etiqueta de seção, levemente torta, como um adesivo.
class RetroSectionLabel extends StatelessWidget {
  const RetroSectionLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    final p = RetroPalette.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Transform.rotate(
        angle: -0.02,
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: p.accent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: p.ink, width: 3),
          ),
          child: Text(
            text.toUpperCase(),
            style: retroDisplay(context,
                size: 16, color: p.onAccent, letterSpacing: 1.5),
          ),
        ),
      ),
    );
  }
}
