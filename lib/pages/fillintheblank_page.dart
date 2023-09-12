import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_test_app/pages/translation_page.dart';
import 'package:english_test_app/model/question_model.dart';
import 'package:flutter/material.dart';
import 'package:english_test_app/model/score_model.dart';

//穴埋め問題ページ
class FillBlankPage extends StatefulWidget {
  const FillBlankPage({Key? key, required this.title, required this.scoreModel})
      : super(key: key);

  final String title;
  final ScoreModel scoreModel;

  @override
  State<FillBlankPage> createState() => _FillBlankPageState();
}

class _FillBlankPageState extends State<FillBlankPage> {
  List<Question> questionList = []; // 質問のリスト
  int currentQuestionIndex = 0; // 現在の質問のインデックス
  String? result; // 結果
  TextEditingController textController = TextEditingController(); // テキストフィールドのコントローラー
  bool isAnswered = false; // 回答済みかどうか

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }
  
  // Firestoreから質問を取得
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

  // 正解かどうかをチェック
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

  // 次のページへ移動
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

  // 次の質問に移動
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

  // UI部分
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
            if (result != null) Text('Result: $result'), // 結果表示
            SizedBox(height: 8),
            Text('( )を埋めてください'),
            SizedBox(height: 8),
            ...question.sentences.map((sentence) => Column(
              children: [
                Text(sentence),
                SizedBox(height: 8),
              ],
            )).toList(),
            TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: 'Fill in the blank.',
              ),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: isAnswered ? null : () {
                checkAnswer();
              },
              child: Text('Check Answer'),
            ),
            SizedBox(height: 8),
            if (isAnswered) Text('Example Answer: ${question.answers[0]}'), // 正解例表示
            if (isAnswered) SizedBox(height: 8),
            if (isAnswered) ElevatedButton(
              onPressed: goToNextQuestion, // 次へボタン
              child: Text('Next Question'),
            ),
          ],
        ),
      ),
    );
  }
}