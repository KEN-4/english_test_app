// ScoreModelクラスを定義
class ScoreModel {
  // 各スキルごとのスコアを管理するMap
  Map<String, double> scores = {
    'listening': 0.0,
    'speaking': 0.0,
    'grammar': 0.0,
    'vocabulary': 0.0,
  };

  // 指定されたスキルのスコアを加算
  void addScore(String skill, {double additionalScore = 1.0}) {
    scores[skill] = (scores[skill] ?? 0.0) + additionalScore;
    print("Score for $skill after adding: ${scores[skill]}");
  }
  Map<String, dynamic> toMap() {
    return scores;
  }
}
