import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_test_app/pages/dictation_page.dart';
import 'package:english_test_app/model/question_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:english_test_app/model/score_model.dart';

class L2QuestionPage extends StatefulWidget {
  const L2QuestionPage({super.key, required this.title, required this.scoreModel});

  final String title;
  final ScoreModel scoreModel;
  
  @override
  State<L2QuestionPage> createState() => _L2QuestionPageState();
}

class _L2QuestionPageState extends State<L2QuestionPage> {
  List<Question> questionList = [];
  AudioPlayer audioPlayer = AudioPlayer();

  Future<void> playAudio(String storageUrl) async {
    try {
      final String downloadUrl =
          await FirebaseStorage.instance.refFromURL(storageUrl).getDownloadURL();
      await audioPlayer.play(downloadUrl);
    } catch (e) {
      // handle the error here
      print("Error while playing audio: $e");
    }
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

  void checkAnswer(Question question, String selectedChoice) {
    if (question.correctAnswer == selectedChoice) {
      result = '○';
      for (String skill in question.skills) {
        widget.scoreModel.addScore(skill, additionalScore: question.score);
      }
    } else {
      result = '×';
    }

    setState(() {});

    if (currentQuestionIndex >= questionList.length - 1) {
      navigateToNextPage();
    } else {
      goToNextQuestion();
    }
  }

  void navigateToNextPage() {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => DictationQuestionPage(scoreModel: widget.scoreModel)),
      );
    });
  }

  void goToNextQuestion() {
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        currentQuestionIndex++;
        result = null;
      });
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
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            if (result != null) Text('結果: $result'),
            const Text('発音した単語を選んでください'),
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