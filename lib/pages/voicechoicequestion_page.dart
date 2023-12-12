import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_test_app/pages/conversationquestion_page.dart';
import 'package:english_test_app/model/question_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:english_test_app/model/score_model.dart';
import 'package:english_test_app/model/nextquestion_model.dart';

// 4択の聞き取り問題ページ
class VoiceChoiceQuestionPage extends StatefulWidget {
  const VoiceChoiceQuestionPage({Key? key, required this.title, required this.scoreModel}): super(key: key);

  final String title;
  final ScoreModel scoreModel;

  @override
  State<VoiceChoiceQuestionPage> createState() => _VoiceChoiceQuestionPageState();
}

class _VoiceChoiceQuestionPageState extends State<VoiceChoiceQuestionPage> {
  List<Question> questionList = []; // 質問のリスト
  AudioPlayer audioPlayer = AudioPlayer(); // 音声プレイヤー
  int currentQuestionIndex = 0; // 現在の質問のインデックス
  String? result; // 結果
  bool isAnswered = false; // 回答済みかどうか
  NextQuestionModel nextQuestionModel = NextQuestionModel(); // 次の質問に移動するためのモデル

  @override
  void initState() {
    super.initState();
    fetchQuestion();
  }

  // 音声を再生
  Future<void> playAudio(String storageUrl) async {
    try {
      final String downloadUrl =
          await FirebaseStorage.instance.refFromURL(storageUrl).getDownloadURL();
      await audioPlayer.setSource(UrlSource(downloadUrl));
      await audioPlayer.resume(); // この行を追加
    } catch (e) {
      print("Error while playing audio: $e");
    }
  }

  // Firestoreから質問を取得
  Future<void> fetchQuestion() async {
    final questionCollection =
        await FirebaseFirestore.instance.collection('voicechoice').get();
    final docs = questionCollection.docs;
    for (var doc in docs) {
      Question question = Question.fromMap(doc.data());
      questionList.add(question);
    }
    setState(() {});
  }

  // 次のページに遷移
  void navigateToNextPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => ConversationQuestionPage(
            title: 'conversation',
            scoreModel: widget.scoreModel,
          )
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
            if (isAnswered) Text('Result: $result'),
            SizedBox(height: 8),
            const Text('音声に合う選択肢を選んでください'),
            SizedBox(height: 8),
            TextButton(
              onPressed: () {
                playAudio(question.audioUrl);
              },
              child: Text('Play Audio'),
            ),
            SizedBox(height: 8),
            ...question.choices.map((choice) {
              return Column(
                children: [
                  ElevatedButton(
                    onPressed: isAnswered ? null : () => checkAnswer(question, choice),
                    child: Text(choice),
                  ),
                  SizedBox(height: 8),
                ],
              );
            }).toList(),
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