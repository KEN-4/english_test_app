import 'package:audioplayers/audioplayers.dart';
import 'package:english_test_app/pages/voicechoicequestion_page.dart';
import 'package:english_test_app/model/question_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:english_test_app/model/score_model.dart';
import 'package:english_test_app/model/nextquestion_model.dart';

// 書き取り問題ページ
class DictationQuestionPage extends StatefulWidget {
  final ScoreModel scoreModel;

  DictationQuestionPage({required this.scoreModel});

  @override
  _DictationQuestionPageState createState() => _DictationQuestionPageState();
}

class _DictationQuestionPageState extends State<DictationQuestionPage> {
  List<Question> questionList = []; // 質問のリスト
  AudioPlayer audioPlayer = AudioPlayer(); // 音声プレイヤー
  int currentQuestionIndex = 0; // 現在の質問のインデックス
  String? result; // 結果
  TextEditingController textController = TextEditingController(); // テキストフィールドのコントローラー
  bool isAnswered = false; // 回答済みかどうか
  NextQuestionModel nextQuestionModel = NextQuestionModel(); // 次の質問に移動するためのモデル

  // 音声を再生
  Future<void> playAudio(String storageUrl) async {
    try {
      final String downloadUrl =
          await FirebaseStorage.instance.refFromURL(storageUrl).getDownloadURL();
      await audioPlayer.play(downloadUrl);
    } catch (e) {
      print("Error while playing audio: $e");
    }
  }

  // Firestoreから質問を取得
  void fetchQuestion() async {
    try {
      final questionCollection =
          await FirebaseFirestore.instance.collection('dictation').get();
      final docs = questionCollection.docs;
      for (var doc in docs) {
        Question question = Question.fromMap(doc.data());
        questionList.add(question);
      }
      setState(() {});
    } catch (e) {
      print("Error while fetching questions: $e");
    }
  }

  // 初期状態設定
  @override
  void initState() {
    super.initState();
    fetchQuestion();
  }

  // 正解かどうかをチェック
  void checkAnswer(Question question) {
    if (!isAnswered) {
      isAnswered = true;
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
          builder: (context) => VoiceChoiceQuestionPage(
            title: 'Listening Test',
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
        title: Text("Dictation Test"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isAnswered) Text('Result: $result'), // 結果表示
            SizedBox(height: 8),
            const Text('音声を文字起こししてください'), // 指示
            SizedBox(height: 8),
            TextButton(
              onPressed: () {
                playAudio(question.audioUrl); // 音声再生
              },
              child: Text('Play Audio'),
            ),
            SizedBox(height: 8),
            TextField(
              controller: textController, // テキストフィールド
              decoration: InputDecoration(
                hintText: '音声を文字起こししてください',
              ),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: isAnswered ? null : () {
                checkAnswer(question); // 答えをチェック
              },
              child: Text('Check Answer'),
            ),
            SizedBox(height: 8),
            if (isAnswered) Text('Correct Answer: ${question.answers[0]}'), // 正解表示
            if (isAnswered) SizedBox(height: 8),
            if (isAnswered) ElevatedButton(
              onPressed: goToNextQuestion, // 次の質問へ
              child: Text('Next Question'),
            ),
          ],
        ),
      ),
    );
  }
}
