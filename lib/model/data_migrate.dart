import 'package:cloud_firestore/cloud_firestore.dart';

void migrateData() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // 既存のコレクションからデータを取得
  QuerySnapshot oldCollectionSnapshot = await firestore.collection('old_collection').get();

  // 新しいコレクションにデータを追加
//   for (var doc in oldCollectionSnapshot.docs) {
//     await firestore.collection('new_collection').add(doc.data());
//   }
}

// // この関数を呼び出して、データ移行を開始
// migrateData();