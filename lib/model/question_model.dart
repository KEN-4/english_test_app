class Question {
  final String audioUrl;
  final List<String> choices;
  final String correctAnswer;
  final String type;
  final List<String> skills;
  final List<String> sentences;
  final List<String> answers;
  final double score;

  Question(this.audioUrl, this.choices, this.correctAnswer, this.type,
      this.skills, this.sentences, this.answers, this.score);

  // fromMap ファクトリーコンストラクタ
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      map['audioUrl'] ?? '',
      map['choices'] == null ? [] : List<String>.from(map['choices']),
      map['correctAnswer'] ?? '',
      map['type'] ?? '',
      map['skills'] == null ? [] : List<String>.from(map['skills']),
      map['sentences'] == null ? [] : List<String>.from(map['sentences']),
      map['answers'] == null ? [] : List<String>.from(map['answers']),
      map['score'] != null ? map['score'].toDouble() : 1.0,
    );
  }
}
