import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_test_app/%20pages/result_page.dart';
import 'package:english_test_app/%20pages/translation_page.dart';
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

  void fetchQuestion() async {
    final questionCollection =
        await FirebaseFirestore.instance.collection('fillintheblank').get();
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

  void checkAnswer(Question question) {
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

    if (currentQuestionIndex >= questionList.length - 1) {
      Future.delayed(Duration(seconds: 2), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => TranslationPage(
              title: 'translation',
              scoreModel: widget.scoreModel,),
          ),
        );
      });
    } else {
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) {  // ウィジェットがマウントされているかどうか確認
          setState(() {
            currentQuestionIndex++;
            result = null;
          });
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
      appBar: AppBar(title: Text('Translation Question')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (result != null) Text('Result: $result'),
            ...question.sentences.map((sentence) => Text(sentence)).toList(),
            TextField(
              controller: textController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Answer',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                checkAnswer(question);
              },
              child: Text('Check Answer'),
            ),
          ],
        ),
      ),
    );
  }
}