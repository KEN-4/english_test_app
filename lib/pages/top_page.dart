import 'package:english_test_app/pages/l2question_page.dart';
import 'package:english_test_app/model/score_model.dart';
import 'package:flutter/material.dart';

class TopPage extends StatelessWidget {
  const TopPage({Key? key}) : super(key: key);

  // Function to handle button press
  void _onStartTestPressed(BuildContext context) {
    ScoreModel scoreModel = ScoreModel();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => L2QuestionPage(
          title: 'Listening Page',
          scoreModel: scoreModel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('English Test'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _onStartTestPressed(context),
          child: const Text('診断開始'),
        ),
      ),
    );
  }
}
