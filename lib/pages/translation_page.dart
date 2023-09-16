import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_test_app/pages/choicequestion_page.dart';
import 'package:english_test_app/model/question_model.dart';
import 'package:flutter/material.dart';
import 'package:english_test_app/model/score_model.dart';
import 'package:english_test_app/model/nextquestion_model.dart';

// 翻訳問題ページ
class TranslationPage extends StatefulWidget {
  const TranslationPage({Key? key, required this.title, required this.scoreModel})
      : super(key: key);

  final String title;
  final ScoreModel scoreModel;

  @override
  State<TranslationPage> createState() => _TranslationPageState();
}

class _TranslationPageState extends State<TranslationPage> {
  List<Question> questionList = []; // 質問のリスト
  int currentQuestionIndex = 0; // 現在の質問のインデックス
  String? result; // 結果
  TextEditingController textController = TextEditingController(); // テキストフィールドのコントローラー
  bool isAnswered = false; // 回答済みかどうか
  NextQuestionModel nextQuestionModel = NextQuestionModel(); // 次の質問に移動するためのモデル

  @override
  void initState() {
    super.initState();
    fetchQuestion();
  }

  // Firestoreから質問を取得
  void fetchQuestion() async {
    final questionCollection = await FirebaseFirestore.instance.collection('translation').get();
    final docs = questionCollection.docs;
    for (var doc in docs) {
      Question question = Question.fromMap(doc.data());
      questionList.add(question);
    }
    setState(() {});
  }

  // 次のページに遷移
  void navigateToNextPage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ChoiceQuestionPage(
          title: 'Choice Test',
          scoreModel: widget.scoreModel,),
      ),
    );
  }

  // 次の問題に遷移
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

  // テキストフィールドに選択肢を追加
  void addChoiceToTextField(String choice) {
    textController.text = textController.text + ' ' + choice;
  }

  // UI部分
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
            if (isAnswered) Text('Result: $result'),
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