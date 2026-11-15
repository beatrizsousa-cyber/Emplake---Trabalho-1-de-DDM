import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:emplake_da_bia/l10n/app_localizations.dart';
import '../core/theme/retro_theme.dart';
import '../core/widgets/retro_widgets.dart';

class ShellScreen extends StatefulWidget {
  final Widget child;
  const ShellScreen({super.key, required this.child});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  final GlobalKey<CurvedNavigationBarState> _navKey = GlobalKey();
  int _currentIndex = 0;

  int _indexFor(String location) {
    if (location.startsWith('/history')) return 1;
    if (location.startsWith('/settings')) return 2;
    return 0;
  }

  Future<void> _showHelpDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      // Passar o barrierLabel evita depender do MaterialLocalizations
      // só para abrir o diálogo.
      barrierLabel: l10n.gotIt,
      builder: (ctx) => const _HelpDialog(),
    );
    // Devolve o destaque da barra para a página atual.
    _navKey.currentState?.setPage(_currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    _currentIndex = _indexFor(GoRouterState.of(context).uri.path);
    final p = RetroPalette.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: p.paper,
      body: widget.child,
      bottomNavigationBar: CurvedNavigationBar(
        key: _navKey,
        index: _currentIndex,
        height: 62,
        color: p.ink,
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: p.accent,
        animationDuration: const Duration(milliseconds: 300),
        items: [
          Tooltip(
            message: l10n.gameTitle,
            child: Icon(Icons.sports_esports_rounded, size: 30, color: p.paper),
          ),
          Tooltip(
            message: l10n.history,
            child: Icon(Icons.history_edu_rounded, size: 30, color: p.paper),
          ),
          Tooltip(
            message: l10n.settings,
            child: Icon(Icons.settings_rounded, size: 30, color: p.paper),
          ),
          Tooltip(
            message: l10n.help,
            child: Icon(Icons.help_outline_rounded, size: 30, color: p.paper),
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/game');
              break;
            case 1:
              context.go('/history');
              break;
            case 2:
              context.go('/settings');
              break;
            case 3:
              _showHelpDialog(context);
              break;
          }
        },
      ),
    );
  }
}

/// Janela de ajuda no estilo retrô: título com estrelas e os passos
/// numerados em "adesivos". O texto vem do helpDetails (já traduzido):
/// cada linha do texto vira um passo.
class _HelpDialog extends StatelessWidget {
  const _HelpDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = RetroPalette.of(context);

    // "1. Escolha o nível." -> "Escolha o nível."
    final steps = l10n.helpDetails
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .map((s) => s.replaceFirst(RegExp(r'^\d+\.\s*'), ''))
        .toList();

    final star =
        Icon(Icons.star_rounded, color: p.accent, size: 26 * p.fontScale);
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 560, maxHeight: maxHeight),
          child: RetroCard(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Título ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    star,
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        l10n.helpTitle.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: retroDisplay(context, size: 22, shadow: true),
                      ),
                    ),
                    const SizedBox(width: 10),
                    star,
                  ],
                ),
                const SizedBox(height: 10),
                Container(height: 4, color: p.ink),
                const SizedBox(height: 3),
                Container(height: 1.5, color: p.ink),
                const SizedBox(height: 14),

                // ── Passos (rolam se a janela for baixa) ──
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < steps.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 34 * p.fontScale,
                                  height: 34 * p.fontScale,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: p.accent,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: p.ink, width: 3),
                                  ),
                                  child: Text(
                                    '${i + 1}',
                                    style: retroDisplay(context,
                                        size: 16, color: p.onAccent),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      steps[i],
                                      style: TextStyle(
                                        fontSize: 15 * p.fontScale,
                                        height: 1.35,
                                        color: p.ink,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // ── Botão ──
                Align(
                  alignment: Alignment.center,
                  child: RetroButton(
                    onPressed: () => Navigator.of(context).pop(),
                    color: p.accent,
                    foreground: p.onAccent,
                    child: Text(l10n.gotIt.toUpperCase(),
                        style: retroDisplay(context, size: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
