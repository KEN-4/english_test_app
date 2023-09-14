import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_test_app/pages/dictation_page.dart';
import 'package:english_test_app/model/question_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:english_test_app/model/score_model.dart';
import 'package:english_test_app/model/nextquestion_model.dart';

// 2択の聞き取り問題ページ
class L2QuestionPage extends StatefulWidget {
  const L2QuestionPage({super.key, required this.title, required this.scoreModel});

  final String title;
  final ScoreModel scoreModel;

  @override
  State<L2QuestionPage> createState() => _L2QuestionPageState();
}

class _L2QuestionPageState extends State<L2QuestionPage> {
  List<Question> questionList = []; // 質問のリスト
  AudioPlayer audioPlayer = AudioPlayer(); // 音声プレイヤー
  bool isAnswered = false; // 回答済みかどうか
  int currentQuestionIndex = 0; // 現在の質問のインデックス
  String? result; // 結果
  NextQuestionModel nextQuestionModel = NextQuestionModel(); // 次の質問に移動するためのモデル

  // 音声を再生
  Future<void> playAudio(String storageUrl) async {
    try {
      final String downloadUrl = await FirebaseStorage.instance.refFromURL(storageUrl).getDownloadURL();
      await audioPlayer.play(downloadUrl);
    } catch (e) {
      print("Error while playing audio: $e");
    }
  }

  // Firestoreから質問を取得
  void fetchQuestion() async {
    final questionCollection = await FirebaseFirestore.instance.collection('listening_2choice').get();
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

  // 次の問題へ移動
  void goToNextQuestion() {
    nextQuestionModel.goToNextQuestion(
      questionList,
      currentQuestionIndex,
      (val) => setState(() => isAnswered = val),
      (val) => setState(() => currentQuestionIndex = val),
      () => navigateToNextPage()
    ); 
  }

  // 次のページへ移動
  void navigateToNextPage() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DictationQuestionPage(scoreModel: widget.scoreModel),
        ),
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

    var question = questionList[currentQuestionIndex];
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (result != null) Text('Result: $result'),
            SizedBox(height: 8),
            const Text('発音した単語を選んでください'),
            SizedBox(height: 8),
            TextButton(
              onPressed: isAnswered ? null : () {
                playAudio(question.audioUrl);
              },
              child: Text('Play Audio'),
            ),
            SizedBox(height: 8),
            ...question.choices.expand((choice) => [
              ElevatedButton(
                onPressed: isAnswered ? null : () {
                  checkAnswer(question, choice);
                },
                child: Text(choice),
              ),
              SizedBox(height: 8),
            ]).toList(),
            if (isAnswered) Text('Correct Answer: ${question.correctAnswer}'),
            SizedBox(height: 8),
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