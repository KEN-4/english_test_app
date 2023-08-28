import 'package:english_test_app/model/score_model.dart';
import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final ScoreModel scoreModel;

  ResultPage({required this.scoreModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Result'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Listening Score: ${scoreModel.scores['listening'] ?? 0}'),
            Text('Speaking Score: ${scoreModel.scores['speaking'] ?? 0}'),
            Text('Grammar Score: ${scoreModel.scores['grammar'] ?? 0}'),
            Text('Vocabulary Score: ${scoreModel.scores['vocabulary'] ?? 0}'),
          ],
        ),
      ),
    );
  }
}
