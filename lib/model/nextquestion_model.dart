import 'package:english_test_app/model/question_model.dart';

class NextQuestionModel {
  void goToNextQuestion(List<Question> questionList, int currentQuestionIndex, Function setIsAnswered, Function setCurrentQuestionIndex, Function navigateToNextPage) {
    if (currentQuestionIndex >= questionList.length - 1) {
      navigateToNextPage();
    } else {
      setIsAnswered(false);
      setCurrentQuestionIndex(currentQuestionIndex + 1);
    }
  }
}
