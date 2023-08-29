class ScoreModel {
  Map<String, double> scores = {
    'listening': 0.0,
    'speaking': 0.0,
    'grammar': 0.0,
    'vocabulary': 0.0,
  };

  void addScore(String skill, {double additionalScore = 1.0}) {
    scores[skill] = (scores[skill] ?? 0.0) + additionalScore;
    print("Score for $skill after adding: ${scores[skill]}");
  }
}
