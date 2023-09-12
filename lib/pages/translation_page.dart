import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_test_app/pages/choicequestion_page.dart';
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
  bool isAnswered = false;

  @override
  void initState() {
    super.initState();
    fetchQuestion();
  }

  void fetchQuestion() async {
    final questionCollection = await FirebaseFirestore.instance.collection('translation').get();
    final docs = questionCollection.docs;
    for (var doc in docs) {
      Question question = Question.fromMap(doc.data());
      questionList.add(question);
    }
    setState(() {});
  }

  void navigateToNextPage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ChoiceQuestionPage(
          title: 'Choice Test',
          scoreModel: widget.scoreModel,),
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

  void checkAnswer(Question question) {
    if (!isAnswered) {
      isAnswered = true;
      if (question.correctAnswer == textController.text) {
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

  void addChoiceToTextField(String choice) {
    textController.text = textController.text + ' ' + choice;
  }

  @override
  Widget build(BuildContext context) {
    if (questionList.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }
    var question = questionList[currentQuestionIndex];
    return Scaffold(
      appBar: AppBar(title: Text('Translation Test')),
      body: SingleChildScrollView( // 画面が小さい時にスクロールできるようにする
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (result != null) Text('Result: $result'),
            SizedBox(height: 8),
            const Text('日本語の文を英文に訳してください'),
            SizedBox(height: 8),
            ...question.sentences.map((sentence) => Column(
              children: [
                Text(sentence),
                SizedBox(height: 8),
              ],
            )).toList(),
            ...List.generate(question.choices.length, (index) => Column(
              children: [
                ElevatedButton(
                  onPressed: () => addChoiceToTextField(question.choices[index]),
                  child: Text(question.choices[index]),
                ),
                SizedBox(height: 8),
              ],
            )),
            TextField(
              controller: textController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Add text by pressing the button',
              ),
              enabled: !isAnswered,
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: isAnswered ? null : () => checkAnswer(question),
              child: Text('Check Answer'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => textController.clear(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Clear'),
            ),
            SizedBox(height: 8),
            if (isAnswered) Text('Correct Answer: ${question.correctAnswer}'),
            if (isAnswered) SizedBox(height: 8),
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