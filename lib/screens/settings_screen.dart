import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import 'package:emplake_da_bia/l10n/app_localizations.dart';
import '../core/providers/game_providers.dart';
import '../core/theme/retro_theme.dart';
import '../core/theme/theme_provider.dart';
import '../core/widgets/retro_widgets.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const List<Color> _seedColors = [
    Color(0xFFD64045), // vermelho
    Color(0xFFE76F51), // laranja
    Color(0xFF2A9D8F), // verde-água
    Color(0xFF3A6EA5), // azul
    Color(0xFF5B8E3E), // verde
    Color(0xFF7B4B94), // roxo
  ];

  // Nomes exatos do Google Fonts.
  static const List<String> _fontFamilies = [
    'Nunito',
    'Oswald',
    'Special Elite',
    'Roboto',
    'EB Garamond',
    'Lato',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final p = RetroPalette.of(context);
    final settings = ref.watch(themeProvider);
    final notifier = ref.read(themeProvider.notifier);
    final soundOn = ref.watch(soundProvider);

    Widget modeButton(ThemeMode mode, IconData icon, String label) {
      final selected = settings.themeMode == mode;
      return RetroButton(
        onPressed: () => notifier.updateThemeMode(mode),
        color: selected ? p.accent : p.card,
        foreground: selected ? p.onAccent : p.ink,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 6),
            Text(label, style: retroSymbol(context, size: 15)),
          ],
        ),
      );
    }

    return RetroScaffold(
      title: l10n.settings,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          // ── Aparência ──
          RetroSectionLabel(l10n.appearance),
          const SizedBox(height: 14),
          RetroCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.themeMode, style: retroDisplay(context, size: 18)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    modeButton(ThemeMode.light, Icons.wb_sunny_rounded,
                        l10n.themeLight),
                    modeButton(ThemeMode.dark, Icons.nights_stay_rounded,
                        l10n.themeDark),
                    modeButton(ThemeMode.system, Icons.brightness_auto_rounded,
                        l10n.themeSystem),
                  ],
                ),
                const SizedBox(height: 24),
                Text(l10n.seedColor, style: retroDisplay(context, size: 18)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: _seedColors.map((c) {
                    final selected =
                        settings.seedColor.toARGB32() == c.toARGB32();
                    return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => notifier.updateSeedColor(c),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: p.ink, width: selected ? 4 : 2),
                            boxShadow: selected
                                ? [
                                    BoxShadow(
                                        color: p.ink,
                                        offset: const Offset(3, 3))
                                  ]
                                : null,
                          ),
                          child: selected
                              ? const Icon(Icons.check_rounded,
                                  color: Colors.white)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Tipografia ──
          RetroSectionLabel(l10n.typography),
          const SizedBox(height: 14),
          RetroCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${l10n.fontSize}: ${settings.fontSize.toInt()}',
                    style: retroDisplay(context, size: 18)),
                Slider(
                  value: settings.fontSize,
                  min: 12,
                  max: 24,
                  divisions: 6,
                  label: '${settings.fontSize.toInt()}',
                  onChanged: notifier.updateFontSize,
                ),
                const SizedBox(height: 12),
                Text(l10n.fontFamily, style: retroDisplay(context, size: 18)),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  isExpanded: true,
                  value: _fontFamilies.contains(settings.fontFamily)
                      ? settings.fontFamily
                      : _fontFamilies.first,
                  dropdownColor: p.card,
                  borderRadius: BorderRadius.circular(12),
                  underline: Container(height: 3, color: p.ink),
                  items: _fontFamilies
                      .map((f) => DropdownMenuItem(
                            value: f,
                            child: Text(f,
                                style: GoogleFonts.getFont(f, fontSize: 18)),
                          ))
                      .toList(),
                  onChanged: (f) {
                    if (f != null) notifier.updateFontFamily(f);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Som (opcional, desligado por padrão) ──
          RetroSectionLabel(l10n.soundEnabled),
          const SizedBox(height: 14),
          RetroCard(
            child: Row(
              children: [
                Icon(
                    soundOn
                        ? Icons.volume_up_rounded
                        : Icons.volume_off_rounded,
                    size: 30),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.soundEnabled,
                          style: retroDisplay(context, size: 18)),
                      Text(
                        l10n.soundSubtitle,
                        style: TextStyle(
                          fontSize: 13 * p.fontScale,
                          color: p.ink.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: soundOn,
                  activeTrackColor: p.accent,
                  activeThumbColor: p.onAccent,
                  inactiveTrackColor: p.paperDeep,
                  inactiveThumbColor: p.ink,
                  trackOutlineColor: WidgetStatePropertyAll(p.ink),
                  onChanged: ref.read(soundProvider.notifier).setEnabled,
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Sair (volta para a tela de login) ──
          RetroButton(
            onPressed: () => FirebaseAuth.instance.signOut(),
            color: p.card,
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.logout_rounded, size: 22),
                const SizedBox(width: 8),
                Text(l10n.logout.toUpperCase(),
                    style: retroDisplay(context, size: 17)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
