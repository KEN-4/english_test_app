import 'package:english_test_app/pages/login_page.dart';
import 'package:english_test_app/firebase_options.dart';
import 'package:english_test_app/test/test_login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebaseを初期化
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // テストモードのフラグ
  bool isTestMode = false; // テストモードを有効にするにはtrueに設定

  // アプリを起動
  runApp(MyApp(isTestMode: isTestMode));
}

class MyApp extends StatelessWidget {
  final bool isTestMode;

  const MyApp({Key? key, required this.isTestMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'English Test App',  // アプリのタイトル
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true, 
      ),
      home: isTestMode ? TestLoginPage() : LoginPage(),  // テストモードに基づいて表示するページを変更
    );
  }
}
