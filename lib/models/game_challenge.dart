class GameChallenge {
  final String id;
  final List<int> digits;
  final bool isSolved;
  final String? solvedAt;

  GameChallenge({
    required this.id,
    required this.digits,
    this.isSolved = false,
    this.solvedAt,
  });

  /// Cria uma cópia com campos alterados (útil para marcar como resolvido).
  GameChallenge copyWith({
    String? id,
    List<int>? digits,
    bool? isSolved,
    String? solvedAt,
  }) {
    return GameChallenge(
      id: id ?? this.id,
      digits: digits ?? this.digits,
      isSolved: isSolved ?? this.isSolved,
      solvedAt: solvedAt ?? this.solvedAt,
    );
  }

  factory GameChallenge.fromMap(Map<String, dynamic> map, String docId) {
    final rawDigits = map['digits'];
    if (rawDigits is! List || rawDigits.length != 4) {
      throw FormatException('Desafio $docId com digits inválidos');
    }
    return GameChallenge(
      id: docId,
      digits: rawDigits.map((e) => (e as num).toInt()).toList(),
      isSolved: map['isSolved'] as bool? ?? false,
      solvedAt: map['solvedAt'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'digits': digits,
      'isSolved': isSolved,
      // Só grava solvedAt se realmente foi resolvido
      if (isSolved) 'solvedAt': solvedAt ?? DateTime.now().toIso8601String(),
    };
  }
}
