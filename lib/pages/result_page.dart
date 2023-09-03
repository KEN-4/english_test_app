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
          children: [
            ...scoreModel.scores.keys.map((key) {
              return Text(
                '$key Score: ${scoreModel.scores[key] ?? 0}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
