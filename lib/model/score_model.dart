class ScoreModel {
  Map<String, int> scores = {
    'listening': 0,
    'speaking': 0,
    'grammar': 0,
    'vocabulary': 0,
  };

  void addScore(String skill) {
    print('Adding score for skill: $skill');
    scores[skill] = (scores[skill] ?? 0) + 1;
    print("Score for $skill after adding: ${scores[skill]}");
  }
}
