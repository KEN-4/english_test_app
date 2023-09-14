import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_test_app/pages/result_page.dart';
import 'package:english_test_app/model/question_model.dart';
import 'package:flutter/material.dart';
import 'package:english_test_app/model/score_model.dart';
import 'package:english_test_app/model/nextquestion_model.dart';

// 4択の問題ページ
class ChoiceQuestionPage extends StatefulWidget {
  const ChoiceQuestionPage({Key? key, required this.title, required this.scoreModel}): super(key: key);

  final String title;
  final ScoreModel scoreModel;

  @override
  State<ChoiceQuestionPage> createState() => _ChoiceQuestionPageState();
}

class _ChoiceQuestionPageState extends State<ChoiceQuestionPage> {
  List<Question> questionList = [];  // 質問のリスト
  int currentQuestionIndex = 0;  // 現在の質問のインデックス
  String? result;  // 結果
  bool isAnswered = false;  // 回答済みかどうか
  NextQuestionModel nextQuestionModel = NextQuestionModel();  // 次の質問に移動するためのモデル
  
  // Firestoreから質問を取得
  void fetchQuestion() async {
    final questionCollection = await FirebaseFirestore.instance.collection('choice').get();
    final docs = questionCollection.docs;
    for (var doc in docs) {
      Question question = Question.fromMap(doc.data());
      questionList.add(question);
    }
    setState(() {});
  }

  // 初期状態設定
  @override
  void initState() {
    super.initState();
    fetchQuestion();
  }

  // 結果ページに移動
  void navigateToResultPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(scoreModel: widget.scoreModel),
      ),
    );
  }

  // 次の質問に移動
  void goToNextQuestion() {
    nextQuestionModel.goToNextQuestion(
      questionList,
      currentQuestionIndex,
      (val) => setState(() => isAnswered = val),
      (val) => setState(() => currentQuestionIndex = val),
      () => navigateToResultPage()
    ); 
  }

  // 正解かどうかをチェック
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

  // UI部分
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
            if (result != null) Text('Result: $result'),  // 結果表示
            SizedBox(height: 8),
            const Text('( )に当てはまる物を選んでください'),
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
                  onPressed: isAnswered ? null : () => checkAnswer(question , question.choices[index]),
                  child: Text(question.choices[index]),
                ),
                SizedBox(height: 8),
              ],
            )),
            if (isAnswered) Text('Answer: ${question.correctAnswer}'),  // 正解表示
            if (isAnswered) SizedBox(height: 8),
            if (isAnswered) ElevatedButton(
              onPressed: goToNextQuestion,  // 次へボタン
              child: Text('Next Question'),
            ),
          ],
        ),
      ),
    );
  }
}
