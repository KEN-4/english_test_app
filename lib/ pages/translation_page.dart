import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_test_app/%20pages/result_page.dart';
import 'package:english_test_app/model/question_model.dart';
import 'package:flutter/material.dart';
import 'package:english_test_app/model/score_model.dart';

class TranslationPage extends StatefulWidget {
  const TranslationPage({Key? key, required this.title, required this.scoreModel})
      : super(key: key);

  final String title;
  final ScoreModel scoreModel;

  @override
  State<TranslationPage> createState() => _TranslationPageState();
}

class _TranslationPageState extends State<TranslationPage> {
  List<Question> questionList = [];
  int currentQuestionIndex = 0;
  String? result;
  TextEditingController textController = TextEditingController();

  void fetchQuestion() async {
    final questionCollection =
        await FirebaseFirestore.instance.collection('translation').get();
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
    if (question.correctAnswer == textController.text.trim()) {
      result = '○';
      for (String skill in question.skills) {
        widget.scoreModel.addScore(skill);
      }
    } else {
      result = '×';
    }

    setState(() {});
    textController.clear();

    if (currentQuestionIndex >= questionList.length - 1) {
      Future.delayed(Duration(seconds: 2), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultPage(scoreModel: widget.scoreModel),
          ),
        );
      });
    } else {
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          currentQuestionIndex++;
          result = null;
        });
      });
    }
  }

void addChoiceToTextField(String choice) {
    textController.text = textController.text + ' ' + choice;  // スペースを追加して新しい単語を追加
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
            ...List.generate(question.choices.length, (index) {
              return ElevatedButton(
                onPressed: () => addChoiceToTextField(question.choices[index]),
                child: Text(question.choices[index]),
              );
            }),
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