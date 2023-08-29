import 'package:english_test_app/%20pages/l2question_page.dart';
import 'package:english_test_app/model/score_model.dart';
import 'package:flutter/material.dart';

class TopPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('English Test'),
      ),
      body: Center(
        child: ElevatedButton(
            onPressed: () {
              ScoreModel scoreModel = ScoreModel(); // ここでScoreModelのインスタンスを作成
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => L2QuestionPage(
                    title: 'Listening Page',
                    scoreModel: scoreModel, // そしてここで渡す
                  ),
                ),
              );
            },
            child: Text('診断開始'),
          ),

      ),
    );
  }
}