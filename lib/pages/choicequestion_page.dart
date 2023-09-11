import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_test_app/pages/result_page.dart';
import 'package:english_test_app/model/question_model.dart';
import 'package:flutter/material.dart';
import 'package:english_test_app/model/score_model.dart';

class ChoiceQuestionPage extends StatefulWidget {
  const ChoiceQuestionPage({Key? key, required this.title, required this.scoreModel}): super(key: key);

  final String title;
  final ScoreModel scoreModel;

  @override
  State<ChoiceQuestionPage> createState() => _ChoiceQuestionPageState();
}

class _ChoiceQuestionPageState extends State<ChoiceQuestionPage> {
  List<Question> questionList = [];
  int currentQuestionIndex = 0;
  String? result;
  bool isAnswered = false;
  
  void fetchQuestion() async {
    final questionCollection = await FirebaseFirestore.instance.collection('choice').get();
    final docs = questionCollection.docs;
    for (var doc in docs) {
      Question question = Question.fromMap(doc.data());
      questionList.add(question);
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    fetchQuestion();
  }

  void navigateToResultPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(scoreModel: widget.scoreModel),
      ),
    );
  }

  void goToNextQuestion() {
    setState(() {
      if (currentQuestionIndex >= questionList.length - 1) {
        navigateToResultPage();
      } else {
        isAnswered = false;
        currentQuestionIndex++;
        result = null;
      }
    });
  }

  void checkAnswer(Question question, String selectedChoice) {
    if (!isAnswered) {
      isAnswered = true;
      if (question.correctAnswer == selectedChoice) {
        result = '○';
        for (String skill in question.skills) {
          widget.scoreModel.addScore(skill, additionalScore: question.score);
        }
      } else {
        result = '×';
      }

      setState(() {});
    }
  }  

  @override
  Widget build(BuildContext context) {
    if (questionList.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }
    var question = questionList[currentQuestionIndex];
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (result != null) Text('Result: $result'),
            const Text('( )に当てはまる物を選んでください'),
            ...question.sentences.map((sentence) => Text(sentence)).toList(),
            ...List.generate(question.choices.length, (index) {
              return ElevatedButton(
                onPressed: isAnswered ? null : () => checkAnswer(question , question.choices[index]),  // 修正
                child: Text(question.choices[index]),
              );
            }),
            if (isAnswered) Text('Answer: ${question.correctAnswer}'),
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
