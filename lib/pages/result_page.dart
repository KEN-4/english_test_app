import 'package:english_test_app/model/recommend_model.dart';
import 'package:english_test_app/model/score_model.dart';
import 'package:english_test_app/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResultPage extends StatefulWidget {
  final ScoreModel scoreModel;

  ResultPage({required this.scoreModel});

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  @override
  void initState() {
    super.initState();
    _saveResultsToFirestore();
  }

  Future<void> _saveResultsToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final uid = user.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'result_scores': widget.scoreModel.scores,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> recommendations = getMostNeededStudyMethods(widget.scoreModel.scores);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'スコア',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            ...widget.scoreModel.scores.entries.map(
              (e) => Text('${capitalizeFirstLetter(e.key)}: ${e.value}'),
            ),
            SizedBox(height: 20),
            Text(
              'おすすめの学習方法',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            ...recommendations.map((rec) => Text(rec)),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                await Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white
              ),
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

String capitalizeFirstLetter(String text) {
  if (text == null || text.isEmpty) {
    return text;
  }
  return text[0].toUpperCase() + text.substring(1).toLowerCase();
}

// スコアからおすすめの学習方法を取得する
List<String> getMostNeededStudyMethods(Map<String, double> scores) {
  List<String> lowestSkills = [];
  double lowestScore = 10.0;

  scores.forEach((skill, score) {
    if (score < lowestScore) {
      lowestScore = score;
      lowestSkills = [skill];
    } else if (score == lowestScore) {
      lowestSkills.add(skill);
    }
  });

  List<String> recommendations = [];
  for (String lowestSkill in lowestSkills) {
    String level;
    if (lowestScore >= 7.0) {
      level = 'advanced';
    } else if (lowestScore >= 4.0) {
      level = 'intermediate';
    } else {
      level = 'beginner';
    }
    String recommendation = studyRecommendations[lowestSkill]?[level] ?? 'No recommendation available';
    recommendations.add(recommendation);
  }

  return recommendations;
}