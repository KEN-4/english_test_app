import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_test_app/pages/l2question_page.dart';
import 'package:english_test_app/model/score_model.dart';
import 'package:english_test_app/pages/result_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TopPage extends StatefulWidget {
  final bool isNewUser;

  TopPage({required this.isNewUser});

  @override
  _TopPageState createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {
  late Future<DocumentSnapshot> resultScoresFuture;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !widget.isNewUser) {
      final uid = user.uid;
      resultScoresFuture =
          FirebaseFirestore.instance.collection('users').doc(uid).get();
    }
  }

  // テスト開始ボタンが押されたときの処理
  void _onStartTestPressed(BuildContext context) {
    ScoreModel scoreModel = ScoreModel();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => L2QuestionPage(
          title: 'Listening Test',
          scoreModel: scoreModel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isNewUser) {
      return Scaffold(
        appBar: AppBar(
          title: Text('English Test'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () => _onStartTestPressed(context),
            child: Text('診断開始'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('English Test'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: resultScoresFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Text('No data found');
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final resultScores = data['result_scores'] as Map<String, dynamic>;

          // エラーチェックを追加
          final Map<String, double> scoresDouble = resultScores.map(
            (key, value) {
              try {
                return MapEntry(key, double.parse(value.toString()));
              } catch (e) {
                return MapEntry(key, 0.0);
              }
            },
          );

          final recommendations = getMostNeededStudyMethods(scoresDouble);

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _onStartTestPressed(context),
                  child: Text('診断開始'),
                ),
                SizedBox(height: 20),
                const Text('前回のスコア'),
                ...scoresDouble.entries.map((e) => Text('${e.key}: ${e.value}')),
                SizedBox(height: 20),
                const Text('前回のおすすめの学習方法'),
                ...recommendations.map((rec) => Text(rec)),
              ],
            ),
          );
        },
      ),
    );
  }
}
