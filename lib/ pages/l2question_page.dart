import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_test_app/%20pages/dictation_page.dart';
import 'package:english_test_app/model/question_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:english_test_app/model/score_model.dart';

class L2QuestionPage extends StatefulWidget {
  const L2QuestionPage({super.key, required this.title});

  final String title;

  @override
  State<L2QuestionPage> createState() => _L2QuestionPageState();
}

class _L2QuestionPageState extends State<L2QuestionPage> {
  List<Question> questionList = [];
  AudioPlayer audioPlayer = AudioPlayer();

  Future<void> playAudio(String storageUrl) async {
    final String downloadUrl =
        await FirebaseStorage.instance.refFromURL(storageUrl).getDownloadURL();
    await audioPlayer.play(downloadUrl);
  }

  void fetchQuestion() async {
    final questionCollection =
        await FirebaseFirestore.instance.collection('listening_2choice').get();
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

  int currentQuestionIndex = 0;
  String? result;

  final scoreModel = ScoreModel();

  void checkAnswer(Question question, String selectedChoice) {
    print('Before adding score in L2QuestionPage: ${scoreModel.scores}');
    if (question.correctAnswer == selectedChoice) {
      result = '○';
      for (String skill in question.skills) {
        scoreModel.addScore(skill);
      }
    } else {
      result = '×';
    }

    print('After adding score in L2QuestionPage: ${scoreModel.scores}');

    setState(() {});

    if (currentQuestionIndex >= questionList.length - 1) {
      Future.delayed(Duration(seconds: 2), () {
        // 2秒待つ
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DictationQuestionPage(scoreModel: this.scoreModel)),
        );
      });
    } else {
      Future.delayed(Duration(seconds: 2), () {
        // 2秒待つ
        setState(() {
          currentQuestionIndex++;
          result = null;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print("L2QuestionPageでのScoreModelのhashCode: ${scoreModel.hashCode}");
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
        // これでボタンなどが中央に配置されます
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // これで要素が中央に来ます
          children: [
            if (result != null) Text('結果: $result'),
            Text('問題 ${currentQuestionIndex + 1}'),
            TextButton(
              onPressed: () {
                playAudio(question.audioUrl);
              },
              child: Text('Play Audio'),
            ),
            ...question.choices.map((choice) {
              return ElevatedButton(
                onPressed: () {
                  checkAnswer(question, choice);
                },
                child: Text(choice),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}