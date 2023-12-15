import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Future<void> migrateData(BuildContext context) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // 既存のコレクションからデータを取得
  QuerySnapshot oldCollectionSnapshot = await firestore.collection('fillintheblank').get();

  // 新しいコレクションにデータを追加
  for (var doc in oldCollectionSnapshot.docs) {
    await firestore.collection('question').add(doc.data() as Map<String, dynamic>);
  }

  // 移行完了のメッセージを表示
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('データ移行完了'))
  );
}
