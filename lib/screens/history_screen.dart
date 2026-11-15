import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:emplake_da_bia/l10n/app_localizations.dart';
import '../core/theme/retro_theme.dart';
import '../core/widgets/retro_widgets.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late final Future<List<Map<String, dynamic>>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _fetchUserHistory();
  }

  Future<List<Map<String, dynamic>>> _fetchUserHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('solved_challenges')
        .orderBy('solvedAt', descending: true)
        .get();

    return snap.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  String _formatDigits(dynamic raw) => raw is List ? raw.join(' ') : '—';

  String? _formatDate(dynamic raw) {
    if (raw is String) {
      final dt = DateTime.tryParse(raw);
      if (dt != null) {
        return '${dt.day.toString().padLeft(2, '0')}/'
            '${dt.month.toString().padLeft(2, '0')}/${dt.year}';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = RetroPalette.of(context);

    return RetroScaffold(
      title: l10n.history,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SpinKitFadingCube(color: p.accent, size: 50),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: RetroCard(
                  color: Theme.of(context).colorScheme.error,
                  child: Text(
                    l10n.historyError,
                    textAlign: TextAlign.center,
                    style: retroDisplay(context,
                        size: 16, color: Theme.of(context).colorScheme.onError),
                  ),
                ),
              ),
            );
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: RetroCard(
                  child: Text(
                    l10n.historyEmpty,
                    textAlign: TextAlign.center,
                    style: retroDisplay(context, size: 18),
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final date = _formatDate(item['solvedAt']) ?? l10n.unknownDate;
              return Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: RetroCard(
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: p.accent,
                          shape: BoxShape.circle,
                          border: Border.all(color: p.ink, width: 3),
                        ),
                        child: Text('${index + 1}',
                            style: retroDisplay(context,
                                size: 18, color: p.onAccent)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.historyDigits(_formatDigits(item['digits'])),
                              style: retroDisplay(context, size: 20),
                            ),
                            const SizedBox(height: 4),
                            Text(l10n
                                .historyFormula('${item['formula'] ?? '—'}')),
                            const SizedBox(height: 2),
                            Text(
                              l10n.historySolvedOn(date),
                              style: TextStyle(
                                  fontSize: 12 * p.fontScale,
                                  color: p.ink.withValues(alpha: 0.6)),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.star_rounded, color: p.gold, size: 34),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
