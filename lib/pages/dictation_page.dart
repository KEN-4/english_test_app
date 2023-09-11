import 'package:audioplayers/audioplayers.dart';
import 'package:english_test_app/pages/voicechoicequestion_page.dart';
import 'package:english_test_app/model/question_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:english_test_app/model/score_model.dart';

class DictationQuestionPage extends StatefulWidget {
  final ScoreModel scoreModel;

  DictationQuestionPage({required this.scoreModel});

  @override
  _DictationQuestionPageState createState() => _DictationQuestionPageState();
}

class _DictationQuestionPageState extends State<DictationQuestionPage> {
  List<Question> questionList = [];
  AudioPlayer audioPlayer = AudioPlayer();
  int currentQuestionIndex = 0;
  String? result;
  TextEditingController textController = TextEditingController();
  bool isAnswered = false;

  Future<void> playAudio(String storageUrl) async {
    try {
      final String downloadUrl =
          await FirebaseStorage.instance.refFromURL(storageUrl).getDownloadURL();
      await audioPlayer.play(downloadUrl);
    } catch (e) {
      print("Error while playing audio: $e");
    }
  }

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

  @override
  void initState() {
    super.initState();
    fetchQuestion();
  }

  void checkAnswer(Question question) {
    if (!isAnswered) {
      isAnswered = true;
      if (question.correctAnswer == textController.text.trim()) {
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
            if (result != null) Text('Result: $result'),
            const Text('音声を文字起こししてください'),
            TextButton(
              onPressed: () {
                playAudio(question.audioUrl);
              },
              child: Text('Play Audio'),
            ),
            TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: '音声を文字起こししてください',
              ),
            ),
            ElevatedButton(
              onPressed: isAnswered ? null : () {
                checkAnswer(question);
              },
              child: Text('Check Answer'),
            ),
            if (isAnswered) Text('Answer: ${question.correctAnswer}'),
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
