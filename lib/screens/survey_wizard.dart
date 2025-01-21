import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_state.dart';
import 'bottom_nav_screen.dart';

class SurveyWizard extends StatefulWidget {
  @override
  _SurveyWizardState createState() => _SurveyWizardState();
}

class _SurveyWizardState extends State<SurveyWizard> {
  int _currentStep = 0;

  double? _currentWeight;
  double? _targetWeight;
  String? _userName;

  // TextField 컨트롤러
  final _weightController = TextEditingController();
  final _targetController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text('첫 설정')),
      body: _buildStep(context),
    );
  }

  Widget _buildStep(BuildContext context) {
    switch (_currentStep) {
      case 0:
        return _buildWeightStep();
      case 1:
        return _buildTargetStep();
      case 2:
        return _buildNameStep();
      default:
        return SizedBox.shrink();
    }
  }

  // ───────── (1) 현재 체중 입력 스텝 ─────────
  Widget _buildWeightStep() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('현재 체중을 입력해주세요.', style: TextStyle(fontSize: 20)),
            SizedBox(height: 16),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(suffix: Text('kg')),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final w = double.tryParse(_weightController.text);
                if (w != null) {
                  _currentWeight = w;
                  setState(() {
                    _currentStep = 1;
                    _weightController.clear();
                  });
                }
              },
              child: Text('다음'),
            ),
          ],
        ),
      ),
    );
  }

  // ───────── (2) 목표 체중 입력 스텝 ─────────
  Widget _buildTargetStep() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('목표 체중을 입력해주세요.', style: TextStyle(fontSize: 20)),
            SizedBox(height: 16),
            TextField(
              controller: _targetController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(suffix: Text('kg')),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () {
                    setState(() => _currentStep = 0);
                  },
                  child: Text('이전'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final t = double.tryParse(_targetController.text);
                    if (t != null) {
                      _targetWeight = t;
                      setState(() {
                        _currentStep = 2;
                        _targetController.clear();
                      });
                    }
                  },
                  child: Text('다음'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ───────── (3) 이름 입력 스텝 ─────────
  Widget _buildNameStep() {
    final appState = Provider.of<AppState>(context, listen: false);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('이름을 입력해주세요.', style: TextStyle(fontSize: 20)),
            SizedBox(height: 16),
            TextField(
              controller: _nameController,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () {
                    setState(() => _currentStep = 1);
                  },
                  child: Text('이전'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = _nameController.text.trim();
                    if (name.isNotEmpty && _currentWeight != null && _targetWeight != null) {
                      // AppState에 반영
                      appState.completeSurvey(
                        currentW: _currentWeight!,
                        targetW: _targetWeight!,
                        name: name,
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => BottomNavScreen()),
                      );
                      _nameController.clear();
                    }
                  },
                  child: Text('완료'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
