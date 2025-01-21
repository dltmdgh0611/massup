import 'package:flutter/material.dart';

class PremiumView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('프리미엄'),
      ),
      body: Center(
        child: Text(
          '업데이트 예정',
          style: TextStyle(fontSize: 20, color: Colors.grey),
        ),
      ),
    );
  }
}
