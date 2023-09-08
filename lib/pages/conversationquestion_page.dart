import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_test_app/pages/fillintheblank_page.dart';
import 'package:english_test_app/model/question_model.dart';
import 'package:flutter/material.dart';
import 'package:english_test_app/model/score_model.dart';

class ConversationQuestionPage extends StatefulWidget {
  const ConversationQuestionPage({Key? key, required this.title, required this.scoreModel}): super(key: key);

  final String title;
  final ScoreModel scoreModel;

  @override
  State<ConversationQuestionPage> createState() => _ConversationQuestionPageState();
}

class _ConversationQuestionPageState extends State<ConversationQuestionPage> {
  List<Question> questionList = [];
  int currentQuestionIndex = 0;
  String? result;
  bool isButtonDisabled = false;

  @override
  void initState() {
    super.initState();
    fetchQuestion();
  }

  void fetchQuestion() async {
    final questionCollection =
        await FirebaseFirestore.instance.collection('conversation').get();
    final docs = questionCollection.docs;
    for (var doc in docs) {
      Question question = Question.fromMap(doc.data());
      questionList.add(question);
    }
    setState(() {});
  }

  void navigateToNextPage() {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => FillBlankPage(
              title: 'Fill in the blank Test',
              scoreModel: widget.scoreModel,
            )
        ),
      );
    });
  }

  void goToNextQuestion() {
    setState(() {
      isButtonDisabled = false;
      currentQuestionIndex++;
      result = null;
    });
  }

  void checkAnswer(Question question, String selectedChoice) {
    if (!isButtonDisabled) {
      isButtonDisabled = true;

      if (question.correctAnswer == selectedChoice) {
        result = '○';
        for (String skill in question.skills) {
          widget.scoreModel.addScore(skill, additionalScore: question.score);
        }
      } else {
        result = '×';
      }

      setState(() {});

      Future.delayed(Duration(seconds: 2), () {
        if (currentQuestionIndex >= questionList.length - 1) {
          navigateToNextPage();
        } else {
          goToNextQuestion();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (questionList.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }
    var question = questionList[currentQuestionIndex];
    return Scaffold(
      appBar: AppBar(title: Text('Conversation Test'),),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (result != null) Text('Result: $result'),
            const Text('会話文の続きを選んでください'),
            ...question.sentences.map((sentence) => Text(sentence)).toList(),
            ...List.generate(question.choices.length, (index) {
              return ElevatedButton(
                onPressed: isButtonDisabled ? null : () => checkAnswer(question, question.choices[index]),
                child: Text(question.choices[index]),
              );
            }),
          ],
        ),
      ),
    );
  }
}
