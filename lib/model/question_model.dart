// Questionクラスを定義
class Question {
  final String audioUrl;  // 音声URL
  final List<String> choices;  // 選択肢リスト
  final String correctAnswer;  // 正解
  final String type;  // 問題タイプ
  final List<String> skills;  // スキルリスト
  final List<String> sentences;  // 例文リスト
  final List<String> answers;  // 解答リスト
  final double score;  // スコア

  // コンストラクタ
  Question(this.audioUrl, this.choices, this.correctAnswer, this.type,
      this.skills, this.sentences, this.answers, this.score);

  // Mapからオブジェクトを生成
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