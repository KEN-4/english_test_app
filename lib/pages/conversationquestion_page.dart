import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_test_app/pages/fillintheblank_page.dart';
import 'package:english_test_app/model/question_model.dart';
import 'package:flutter/material.dart';
import 'package:english_test_app/model/score_model.dart';
import 'package:english_test_app/model/nextquestion_model.dart';

// 会話問題ページ
class ConversationQuestionPage extends StatefulWidget {
  const ConversationQuestionPage({Key? key, required this.title, required this.scoreModel}): super(key: key);

  final String title;
  final ScoreModel scoreModel;

  @override
  State<ConversationQuestionPage> createState() => _ConversationQuestionPageState();
}

class _ConversationQuestionPageState extends State<ConversationQuestionPage> {
  List<Question> questionList = [];  // 質問のリスト
  int currentQuestionIndex = 0;  // 現在の質問のインデックス
  String? result;  // 結果
  bool isAnswered = false;  // 回答済みかどうか
  NextQuestionModel nextQuestionModel = NextQuestionModel();  // 次の質問に移動するためのモデル

  // 初期状態設定
  @override
  void initState() {
    super.initState();
    fetchQuestion();
  }

  // Firestoreから質問を取得
  void fetchQuestion() async {
    final questionCollection = await FirebaseFirestore.instance.collection('conversation').get();
    final docs = questionCollection.docs;
    for (var doc in docs) {
      Question question = Question.fromMap(doc.data());
      questionList.add(question);
    }
    setState(() {});
  }

  // 次のページへ移動
  void navigateToNextPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => FillBlankPage(
          title: 'Fill in the blank Test',
          scoreModel: widget.scoreModel,
        ),
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
      () => navigateToNextPage()
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
            if (isAnswered) Text('Result: $result'),  // 結果表示
            SizedBox(height: 8),
            const Text('会話文の続きを選んでください'),  // 指示文
            SizedBox(height: 8),
            ...question.sentences.map((sentence) => Column(
              children: [
                Text(sentence),  // 会話文
                SizedBox(height: 8),
              ],
            )).toList(),
            ...List.generate(question.choices.length, (index) {
              return Column(
                children: [
                  ElevatedButton(
                    onPressed: isAnswered ? null : () => checkAnswer(question, question.choices[index]),  // 選択肢
                    child: Text(question.choices[index]),
                  ),
                  SizedBox(height: 8),
                ],
              );
            }),
            if (isAnswered) Text('Correct Answer: ${question.correctAnswer}'),  // 正解表示
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
