import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_state.dart';

class SettingsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    final nameCtrl = TextEditingController(text: appState.userName);
    final targetCtrl = TextEditingController(text: '${appState.targetWeight}');

    return Scaffold(
      appBar: AppBar(
        title: Text('설정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // (1) 이름 수정
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: '이름',
              ),
            ),
            SizedBox(height: 16),
            // (2) 목표 체중 수정
            TextField(
              controller: targetCtrl,
              decoration: InputDecoration(
                labelText: '목표 체중(kg)',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final newName = nameCtrl.text.trim();
                final newTarget = double.tryParse(targetCtrl.text);
                if (newName.isNotEmpty && newTarget != null) {
                  appState.updateUserInfo(newName: newName, newTarget: newTarget);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('설정이 저장되었습니다.'),
                    ),
                  );
                }
              },
              child: Text('저장'),
            ),
          ],
        ),
      ),
    );
  }
}
