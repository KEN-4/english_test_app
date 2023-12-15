import 'package:english_test_app/test/data_migrate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TestLoginPage extends StatefulWidget {
  @override
  _TestLoginPageState createState() => _TestLoginPageState();
}

class _TestLoginPageState extends State<TestLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('テストモード ログイン')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'メールアドレス'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'パスワード'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  // 入力されたメールアドレスとパスワードを使用してログイン
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: _emailController.text,
                    password: _passwordController.text,
                  );
                  // ログイン成功後、データ移行を実行
                  migrateData(context);
                } on FirebaseAuthException catch (e) {
                  // ログイン失敗時の処理
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('ログイン失敗: ${e.message}')),
                  );
                }
              },
              child: Text('ログインしてデータ移行を実行'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
