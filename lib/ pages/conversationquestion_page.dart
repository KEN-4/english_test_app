import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_test_app/%20pages/fillintheblank_page.dart';
import 'package:english_test_app/%20pages/result_page.dart';
import 'package:english_test_app/model/question_model.dart';
import 'package:flutter/material.dart';
import 'package:english_test_app/model/score_model.dart';

class ConversationQuestionPage extends StatefulWidget {
  const ConversationQuestionPage({Key? key, required this.title, required this.scoreModel}): super(key: key);

  final String title;
  final ScoreModel scoreModel;

  @override
  State<ConversationQuestionPage> createState() => _ConversationQuestionPageState();
}

class _ConversationQuestionPageState extends State<ConversationQuestionPage> {
  List<Question> questionList = [];
  int currentQuestionIndex = 0;
  String? result;
  final scoreModel = ScoreModel();
  
  void fetchQuestion() async {
    final questionCollection =
        await FirebaseFirestore.instance.collection('conversation').get();
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


  void checkAnswer(Question question, String selectedChoice) {
    if (question.correctAnswer == selectedChoice) {
      result = '○';
      for (String skill in question.skills) {
        widget.scoreModel.addScore(skill);
      }
    } else {
      result = '×';
    }

    setState(() {});

    if (currentQuestionIndex >= questionList.length - 1) {
      Future.delayed(Duration(seconds: 2), () {
        // 2秒待つ
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => FillBlankPage(
              title: 'voicechoice',
              scoreModel: widget.scoreModel,),
          ),
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
    if (questionList.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }
    var question = questionList[currentQuestionIndex];
    return Scaffold(
    appBar: AppBar(title: Text('Conversation Question')),
    body: Center(
     child: Column(
       mainAxisAlignment: MainAxisAlignment.center,
       children: [
         if (result != null) Text('Result: $result'),  
         ...question.sentences.map((sentence) => Text(sentence)).toList(), 
         ...List.generate(question.choices.length, (index) {
          return ElevatedButton(
            onPressed: () => checkAnswer(question , question.choices[index]),
            child: Text(question.choices[index]),
          );
        }),
      ],
    ),
  ),
);

  }
}