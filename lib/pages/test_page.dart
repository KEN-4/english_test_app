import 'package:english_test_app/model/data_migrate.dart';
import 'package:flutter/material.dart';

class TestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('データ移行テスト')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => migrateData(),
          child: Text('データ移行開始'),
        ),
      ),
    );
  }
}
