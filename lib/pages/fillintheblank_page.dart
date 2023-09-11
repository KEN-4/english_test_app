import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_test_app/pages/translation_page.dart';
import 'package:english_test_app/model/question_model.dart';
import 'package:flutter/material.dart';
import 'package:english_test_app/model/score_model.dart';

class FillBlankPage extends StatefulWidget {
  const FillBlankPage({Key? key, required this.title, required this.scoreModel})
      : super(key: key);

  final String title;
  final ScoreModel scoreModel;

  @override
  State<FillBlankPage> createState() => _FillBlankPageState();
}

class _FillBlankPageState extends State<FillBlankPage> {
  List<Question> questionList = [];
  int currentQuestionIndex = 0;
  String? result;
  TextEditingController textController = TextEditingController();
  bool isAnswered = false;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    try {
      final questionCollection =
          await FirebaseFirestore.instance.collection('fillintheblank').get();
      questionList = questionCollection.docs
          .map((doc) => Question.fromMap(doc.data()))
          .toList();
      setState(() {});
    } catch (e) {
      print("Error while fetching questions: $e");
    }
  }

  void checkAnswer() {
    if (!isAnswered) {
      isAnswered = true;
      Question question = questionList[currentQuestionIndex];
      if (question.answers.contains(textController.text.trim())) {
        result = '○';
        for (String skill in question.skills) {
          widget.scoreModel.addScore(skill, additionalScore: question.score);
        }
      } else {
        result = '×';
      }
      setState(() {});
      textController.clear();
    }
  }

  void navigateToNextPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TranslationPage(
          title: 'translation',
          scoreModel: widget.scoreModel,
        ),
      ),
    );
  }

  void goToNextQuestion() {
    setState(() {
      if (currentQuestionIndex >= questionList.length - 1) {
        navigateToNextPage();
      } else {
        isAnswered = false;
        currentQuestionIndex++;
        result = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (questionList.isEmpty) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    Question question = questionList[currentQuestionIndex];
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (result != null) Text('Result: $result'),
            Text('Please fill in the blank.'),
            ...question.sentences.map((sentence) => Text(sentence)).toList(),
            TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: 'Fill in the blank.',
              ),
            ),
            ElevatedButton(
              onPressed: isAnswered ? null : () {
                checkAnswer();
              },
              child: Text('Check Answer'),
            ),
            if (isAnswered) Text('Example Answer: ${question.answers[0]}'),
            if (isAnswered) ElevatedButton(
              onPressed: goToNextQuestion,
              child: Text('Next Question'),
            ),
          ],
        ),
      ),
    );
  }
}
