import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_test_app/pages/translation_page.dart';
import 'package:english_test_app/model/question_model.dart';
import 'package:flutter/material.dart';
import 'package:english_test_app/model/score_model.dart';
import 'package:english_test_app/model/nextquestion_model.dart';

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
  NextQuestionModel nextQuestionModel = NextQuestionModel(); // 次の質問に移動するためのモデル

  // Firestoreから特定タイプの質問を取得
  void fetchQuestion() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot snapshot = await firestore
        .collection('question')
        .where('type', isEqualTo: 'fill_in_the_blank') // ここでフィルタリング
        .get();

    questionList = snapshot.docs
        .map((doc) => Question.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
    
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    fetchQuestion(); // 質問データを取得
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
    nextQuestionModel.goToNextQuestion(
      questionList,
      currentQuestionIndex,
      (val) => setState(() => isAnswered = val),
      (val) => setState(() => currentQuestionIndex = val),
      () => navigateToNextPage()
    ); 
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
            if (isAnswered) Text('Result: $result'), // 結果表示
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