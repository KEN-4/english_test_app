import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_test_app/model/question_model.dart';
import 'package:flutter/material.dart';

class QuestionPage extends StatefulWidget {
  const QuestionPage({super.key, required this.title});

  final String title;

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  List<Question> questionList = [];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Listening Test'),
      ),
      body: ListView.builder(
        itemCount: questionList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(questionList[index].choices[0]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}