import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

/// Paleta retrô do jogo. As telas leem as cores daqui, nunca direto.
@immutable
class RetroPalette extends ThemeExtension<RetroPalette> {
  const RetroPalette({
    required this.paper,
    required this.paperDeep,
    required this.card,
    required this.ink,
    required this.accent,
    required this.onAccent,
    required this.gold,
    required this.fontScale,
  });

  final Color paper; // fundo (papel)
  final Color paperDeep; // fundo mais escuro (faixas)
  final Color card; // cartões e botões
  final Color ink; // contornos e texto
  final Color accent; // cor de destaque (vem da cor semente)
  final Color onAccent; // texto sobre o destaque
  final Color gold; // dourado (estrelas e vitória)
  final double fontScale; // tamanho de fonte escolhido nas Configurações

  factory RetroPalette.from({
    required Color seed,
    required Brightness brightness,
    required double fontScale,
  }) {
    final dark = brightness == Brightness.dark;
    final seedIsDark =
        ThemeData.estimateBrightnessForColor(seed) == Brightness.dark;
    return RetroPalette(
      paper: dark ? const Color(0xFF1F1A16) : const Color(0xFFF3E7CB),
      paperDeep: dark ? const Color(0xFF2B241E) : const Color(0xFFE6D5A8),
      card: dark ? const Color(0xFF302821) : const Color(0xFFFFF8E6),
      ink: dark ? const Color(0xFFF3E7CB) : const Color(0xFF1B1B1B),
      accent: seed,
      onAccent: seedIsDark ? const Color(0xFFFFF6DF) : const Color(0xFF1B1B1B),
      gold: const Color(0xFFF2B134),
      fontScale: fontScale,
    );
  }

  static RetroPalette of(BuildContext context) =>
      Theme.of(context).extension<RetroPalette>()!;

  @override
  RetroPalette copyWith({
    Color? paper,
    Color? paperDeep,
    Color? card,
    Color? ink,
    Color? accent,
    Color? onAccent,
    Color? gold,
    double? fontScale,
  }) {
    return RetroPalette(
      paper: paper ?? this.paper,
      paperDeep: paperDeep ?? this.paperDeep,
      card: card ?? this.card,
      ink: ink ?? this.ink,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      gold: gold ?? this.gold,
      fontScale: fontScale ?? this.fontScale,
    );
  }

  @override
  RetroPalette lerp(ThemeExtension<RetroPalette>? other, double t) {
    if (other is! RetroPalette) return this;
    return RetroPalette(
      paper: Color.lerp(paper, other.paper, t)!,
      paperDeep: Color.lerp(paperDeep, other.paperDeep, t)!,
      card: Color.lerp(card, other.card, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      fontScale: fontScale + (other.fontScale - fontScale) * t,
    );
  }
}

/// Fonte "de desenho animado" para títulos e números grandes.
/// A cor, se não for informada, é herdada de quem está em volta.
TextStyle retroDisplay(
  BuildContext context, {
  double size = 28,
  Color? color,
  double letterSpacing = 1,
  bool shadow = false,
}) {
  final p = RetroPalette.of(context);
  return GoogleFonts.lilitaOne(
    fontSize: size * p.fontScale,
    color: color,
    letterSpacing: letterSpacing,
    shadows:
        shadow ? [Shadow(color: p.accent, offset: const Offset(3, 3))] : null,
  );
}

/// Estilo para símbolos matemáticos e rótulos (usa a fonte escolhida pelo usuário).
TextStyle retroSymbol(BuildContext context, {double size = 24}) {
  final p = RetroPalette.of(context);
  return TextStyle(fontSize: size * p.fontScale, fontWeight: FontWeight.w800);
}

ThemeData buildRetroTheme({
  required Color seed,
  required Brightness brightness,
  required String fontFamily,
  required double fontSize,
}) {
  final scale = fontSize / 16.0;
  final palette = RetroPalette.from(
    seed: seed,
    brightness: brightness,
    fontScale: scale,
  );

  final scheme =
      ColorScheme.fromSeed(seedColor: seed, brightness: brightness).copyWith(
    primary: palette.accent,
    onPrimary: palette.onAccent,
    secondary: palette.gold,
    onSecondary: const Color(0xFF1B1B1B),
    surface: palette.paper,
    onSurface: palette.ink,
    outline: palette.ink,
  );

  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: palette.paper,
  );

  // Por que não usamos TextTheme.apply(fontSizeFactor: ...):
  // alguns estilos do tema vêm SEM tamanho (fontSize nulo) e o apply
  // com fator diferente de 1.0 quebra com
  //   "fontSize != null || (fontSizeFactor == 1.0 && fontSizeDelta == 0.0)".
  // Aqui cada estilo recebe um tamanho (o dele, ou o padrão do Material 3)
  // já multiplicado pela escala escolhida nas Configurações.
  TextStyle font(TextStyle? s, double fallbackSize) {
    return GoogleFonts.getFont(
      fontFamily,
      textStyle: (s ?? const TextStyle()).copyWith(
        fontSize: (s?.fontSize ?? fallbackSize) * scale,
        color: palette.ink,
      ),
    );
  }

  final t = base.textTheme;
  final textTheme = TextTheme(
    displayLarge: font(t.displayLarge, 57),
    displayMedium: font(t.displayMedium, 45),
    displaySmall: font(t.displaySmall, 36),
    headlineLarge: font(t.headlineLarge, 32),
    headlineMedium: font(t.headlineMedium, 28),
    headlineSmall: font(t.headlineSmall, 24),
    titleLarge: font(t.titleLarge, 22),
    titleMedium: font(t.titleMedium, 16),
    titleSmall: font(t.titleSmall, 14),
    bodyLarge: font(t.bodyLarge, 16),
    bodyMedium: font(t.bodyMedium, 14),
    bodySmall: font(t.bodySmall, 12),
    labelLarge: font(t.labelLarge, 14),
    labelMedium: font(t.labelMedium, 12),
    labelSmall: font(t.labelSmall, 11),
  );

  return base.copyWith(
    textTheme: textTheme,
    extensions: [palette],
    sliderTheme: base.sliderTheme.copyWith(
      trackHeight: 8,
      activeTrackColor: palette.accent,
      inactiveTrackColor: palette.paperDeep,
      thumbColor: palette.ink,
    ),
  );
}
