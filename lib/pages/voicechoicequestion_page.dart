import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_test_app/pages/conversationquestion_page.dart';
import 'package:english_test_app/model/question_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:english_test_app/model/score_model.dart';

class VoiceChoiceQuestionPage extends StatefulWidget {
  const VoiceChoiceQuestionPage({Key? key, required this.title, required this.scoreModel}): super(key: key);

  final String title;
  final ScoreModel scoreModel;

  @override
  State<VoiceChoiceQuestionPage> createState() => _VoiceChoiceQuestionPageState();
}

class _VoiceChoiceQuestionPageState extends State<VoiceChoiceQuestionPage> {
  List<Question> questionList = [];
  AudioPlayer audioPlayer = AudioPlayer();
  int currentQuestionIndex = 0;
  String? result;
  bool isAnswered = false;

  @override
  void initState() {
    super.initState();
    fetchQuestion();
  }

  Future<void> playAudio(String storageUrl) async {
    final String downloadUrl =
        await FirebaseStorage.instance.refFromURL(storageUrl).getDownloadURL();
    await audioPlayer.play(downloadUrl);
  }

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
            if (result != null) Text('Result: $result'),
            const Text('音声に合う選択肢を選んでください'),
            TextButton(
              onPressed: () {
                playAudio(question.audioUrl);
              },
              child: Text('Play Audio'),
            ),
            ...question.choices.map((choice) {
              return ElevatedButton(
                onPressed: isAnswered ? null : () => checkAnswer(question, choice),
                child: Text(choice),
              );
            }).toList(),
            if (isAnswered) Text('Answer ${question.correctAnswer}'),
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
