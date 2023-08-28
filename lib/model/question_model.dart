class Question {
  final String audioUrl;
  final List<String> choices;
  final String correctAnswer;
  final String type;
  final List<String> skills;

  Question(
      this.audioUrl, this.choices, this.correctAnswer, this.type, this.skills);

  // fromMap ファクトリーコンストラクタ
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      map['audioUrl'] ?? '',
      map['choices'] == null ? [] : List<String>.from(map['choices']),
      map['correctAnswer'] ?? '',
      map['type'] ?? '',
      map['skills'] == null ? [] : List<String>.from(map['skills']),
    );
  }
}
