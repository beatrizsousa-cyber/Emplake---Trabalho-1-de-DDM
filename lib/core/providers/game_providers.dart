import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/game_challenge.dart';
import '../../models/game_level.dart';
import '../utils/preference_service.dart';

// ─────────────────────────────────────────────────────────────
// Nível selecionado
// ─────────────────────────────────────────────────────────────
final gameLevelProvider = StateProvider<GameLevel>((ref) => GameLevel.facil);

// ─────────────────────────────────────────────────────────────
// Som (opcional, desligado por padrão, guardado no SharedPreferences)
// ─────────────────────────────────────────────────────────────
class SoundNotifier extends StateNotifier<bool> {
  SoundNotifier(this._prefs) : super(_prefs.getSoundEnabled());

  final PreferenceService _prefs;

  void setEnabled(bool value) {
    state = value;
    _prefs.saveSoundEnabled(value);
  }
}

final soundProvider = StateNotifierProvider<SoundNotifier, bool>((ref) {
  return SoundNotifier(ref.watch(preferenceServiceProvider));
});

// ─────────────────────────────────────────────────────────────
// Tabuleiro: os 4 dígitos são FIXOS e a jogadora só escolhe os sinais.
//
// Existem 5 "casas" para sinais:
//   [0] d1 [1] d2 [2] d3 [3] d4 [4]
// Cada casa guarda uma lista de sinais, por exemplo "(" e "√".
// Casa vazia entre dois dígitos = os dígitos se juntam (1 e 2 viram 12).
// ─────────────────────────────────────────────────────────────
class BoardState {
  const BoardState({
    required this.slots,
    this.active = 1,
    this.history = const [],
  });

  factory BoardState.empty() => BoardState(
        slots: List.generate(slotCount, (_) => const <String>[]),
      );

  static const int slotCount = 5;

  /// Sinais colocados em cada casa.
  final List<List<String>> slots;

  /// Casa selecionada (onde o próximo sinal vai entrar).
  final int active;

  /// Ordem em que os sinais foram colocados (índice da casa), para o "Desfazer".
  final List<int> history;

  bool get hasEquals => slots.any((s) => s.contains('='));
  bool get isEmpty => slots.every((s) => s.isEmpty);

  /// Monta a fórmula completa intercalando as casas com os dígitos.
  String expression(List<int> digits) {
    final b = StringBuffer();
    for (var i = 0; i < slotCount; i++) {
      b.writeAll(slots[i]);
      if (i < digits.length) b.write(digits[i]);
    }
    return b.toString();
  }

  BoardState copyWith({
    List<List<String>>? slots,
    int? active,
    List<int>? history,
  }) =>
      BoardState(
        slots: slots ?? this.slots,
        active: active ?? this.active,
        history: history ?? this.history,
      );
}

class BoardNotifier extends StateNotifier<BoardState> {
  BoardNotifier() : super(BoardState.empty());

  void select(int slot) => state = state.copyWith(active: slot);

  void add(String op) {
    if (op == '=' && state.hasEquals) return; // o "=" aparece uma vez só
    final slots = [for (final s in state.slots) [...s]];
    slots[state.active].add(op);
    state = state.copyWith(
      slots: slots,
      history: [...state.history, state.active],
    );
  }

  /// Remove o sinal tocado.
  void removeAt(int slot, int index) {
    final slots = [for (final s in state.slots) [...s]];
    slots[slot].removeAt(index);
    final history = [...state.history];
    final h = history.lastIndexOf(slot);
    if (h != -1) history.removeAt(h);
    state = state.copyWith(slots: slots, history: history);
  }

  void undo() {
    if (state.history.isEmpty) return;
    final slot = state.history.last;
    final slots = [for (final s in state.slots) [...s]];
    slots[slot].removeLast();
    state = state.copyWith(
      slots: slots,
      history: state.history.sublist(0, state.history.length - 1),
    );
  }

  void clear() => state = BoardState.empty().copyWith(active: state.active);
}

final boardProvider = StateNotifierProvider<BoardNotifier, BoardState>((ref) {
  return BoardNotifier();
});

// ─────────────────────────────────────────────────────────────
// Feedback (mensagem + se é sucesso)
// ─────────────────────────────────────────────────────────────
class FeedbackState {
  final String message;
  final bool isSuccess;
  const FeedbackState({this.message = '', this.isSuccess = false});
}

final feedbackProvider =
    StateProvider<FeedbackState>((ref) => const FeedbackState());

// ─────────────────────────────────────────────────────────────
// Usuário logado (o desafio é refeito quando alguém entra ou sai)
// ─────────────────────────────────────────────────────────────
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// ─────────────────────────────────────────────────────────────
// Desafio atual: consulta o Firestore para NÃO repetir números
// já resolvidos ou pulados por esta usuária.
// ─────────────────────────────────────────────────────────────
final challengeProvider = FutureProvider<GameChallenge>((ref) async {
  // Reage a login/logout, para nunca mostrar o desafio de outra conta.
  final user = ref.watch(authStateProvider).valueOrNull ??
      FirebaseAuth.instance.currentUser;
  if (user == null) return _generateRandom();

  final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
  final solvedSnap = await userDoc.collection('solved_challenges').get();
  final skippedSnap = await userDoc.collection('skipped_challenges').get();

  final blocked = <String>{
    ...solvedSnap.docs.map((d) => d.id),
    ...skippedSnap.docs.map((d) => d.id),
  };

  for (var i = 0; i < 200; i++) {
    final candidate = _generateRandom();
    if (!blocked.contains(candidate.id)) return candidate;
  }
  return _generateRandom();
});

/// Sorteia 4 dígitos de 1 a 9. A ordem importa, então o id guarda a ordem.
GameChallenge _generateRandom() {
  final r = Random();
  final digits = List.generate(4, (_) => r.nextInt(9) + 1);
  return GameChallenge(id: 'digits_${digits.join('-')}', digits: digits);
}

// ─────────────────────────────────────────────────────────────
// Ações: salvar resolvido / pulado
// ─────────────────────────────────────────────────────────────
Future<void> saveSolved(GameChallenge challenge, String formula) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;
  await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('solved_challenges')
      .doc(challenge.id)
      .set({
    'digits': challenge.digits,
    'formula': formula,
    'solvedAt': DateTime.now().toIso8601String(),
  });
}

Future<void> saveSkipped(GameChallenge challenge) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;
  await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('skipped_challenges')
      .doc(challenge.id)
      .set({
    'digits': challenge.digits,
    'skippedAt': DateTime.now().toIso8601String(),
  });
}
