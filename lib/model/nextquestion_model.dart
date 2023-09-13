import 'package:english_test_app/model/question_model.dart';

class NextQuestionModel {
  int currentQuestionIndex = 0;
  bool isAnswered = false;
  String? result;

  void goToNextQuestion(List<Question> questionList, Function navigateToNextPage) {
    if (currentQuestionIndex >= questionList.length - 1) {
      navigateToNextPage();
    } else {
      isAnswered = false;
      currentQuestionIndex++;
      result = null;
    }
  }
}
