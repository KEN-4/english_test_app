import 'package:english_test_app/pages/login_page.dart';
import 'package:english_test_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebaseを初期化
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // アプリを起動
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
   const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'English Test App',  // アプリのタイトル
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true, 
      ),
      home: LoginPage(),  // ホームページとしてLoginPageを指定
    );
  }
}
