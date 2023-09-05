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
  bool isButtonDisabled = false;

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
    if (!isButtonDisabled) {
      isButtonDisabled = true;
      
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

      Future.delayed(Duration(seconds: 2), () {
        if (currentQuestionIndex >= questionList.length - 1) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => TranslationPage(
                title: 'translation',
                scoreModel: widget.scoreModel,
              ),
            ),
          );
        } else {
          if (mounted) {
            setState(() {
              isButtonDisabled = false;
              currentQuestionIndex++;
              result = null;
            });
          }
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
      appBar: AppBar(title: Text('Fill in the Blank Question')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (result != null) Text('Result: $result'),
            const Text('会話文の続きを記述してください'),
            ...question.sentences.map((sentence) => Text(sentence)).toList(),
            TextField(
              controller: textController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Answer',
              ),
            ),
            ElevatedButton(
              onPressed: isButtonDisabled ? null : () => checkAnswer(question),
              child: Text('Check Answer'),
            ),
          ],
        ),
      ),
    );
  }
}
