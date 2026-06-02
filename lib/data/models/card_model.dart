class CardModel {
  final int id;
  final String content;
  final int matchId;
  bool isFlipped;
  bool isMatched;

  CardModel({
    required this.id,
    required this.content,
    required this.matchId,
    this.isFlipped = false,
    this.isMatched = false,
  });

  CardModel copyWith({
    int? id,
    String? content,
    int? matchId,
    bool? isFlipped,
    bool? isMatched,
  }) {
    return CardModel(
      id: id ?? this.id,
      content: content ?? this.content,
      matchId: matchId ?? this.matchId,
      isFlipped: isFlipped ?? this.isFlipped,
      isMatched: isMatched ?? this.isMatched,
    );
  }
}
