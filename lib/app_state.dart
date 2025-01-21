import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:convert';

class AppState extends ChangeNotifier {
  final Box box;

  // 기존 상태
  bool isSurveyDone = false;
  String userName = '';
  double currentWeight = 0.0;
  double targetWeight = 0.0;

  // 식단
  final Map<DateTime, Map<String, List<Map<String, dynamic>>>> dailyLogs = {};

  int calorieGoal = 2000;

  AppState(this.box) {
    // (A) 생성자에서 로드
    loadFromHive();
  }

  // ─────────────────────────
  // Hive 저장/로드
  // ─────────────────────────
  Future<void> loadFromHive() async {
    // 1) isSurveyDone, userName, currentWeight, targetWeight
    isSurveyDone = box.get('isSurveyDone', defaultValue: false);
    userName = box.get('userName', defaultValue: '');
    currentWeight = box.get('currentWeight', defaultValue: 0.0);
    targetWeight = box.get('targetWeight', defaultValue: 0.0);
    calorieGoal = box.get('calorieGoal', defaultValue: 2000);

    // 2) dailyLogs (JSON 직렬화)
    final dailyLogsString = box.get('dailyLogs', defaultValue: '');
    if (dailyLogsString.isNotEmpty) {
      // 예: {"2023-07-13":{"아침":[{"name":"밥","calories":300}, ...], ...}}
      Map<String, dynamic> parsed = json.decode(dailyLogsString);
      // string key(yyyy-MM-dd) → DateTime
      dailyLogs.clear();
      parsed.forEach((dateString, mealMap) {
        final dt = DateTime.parse(dateString);
        // mealMap → {'아침': [...], '점심': [...], ...}
        // 그대로 저장
        dailyLogs[dt] = (mealMap as Map).map((mealKey, listVal) {
          final List listData = listVal as List;
          return MapEntry(mealKey, listData.map((e) => e as Map<String, dynamic>).toList());
        });
      });
    }

    notifyListeners();
  }

  Future<void> saveToHive() async {
    // 1) user info
    await box.put('isSurveyDone', isSurveyDone);
    await box.put('userName', userName);
    await box.put('currentWeight', currentWeight);
    await box.put('targetWeight', targetWeight);
    await box.put('calorieGoal', calorieGoal);

    // 2) dailyLogs → JSON 직렬화
    // dailyLogs: Map<DateTime, Map<String, List<Map<String,dynamic>>>>
    final Map<String, dynamic> toSave = {};
    dailyLogs.forEach((date, mealMap) {
      final dateString = date.toIso8601String().split('T')[0];
      // mealMap: {'아침': [...], ...}
      // 그대로
      toSave[dateString] = mealMap;
    });
    final dailyLogsString = json.encode(toSave);
    await box.put('dailyLogs', dailyLogsString);
  }

  // ─────────────────────────
  // 식단 로직
  // ─────────────────────────
  void updateLog(DateTime date, String meal, Map<String, dynamic> log) {
    dailyLogs.putIfAbsent(
      date,
          () => {'아침': [], '점심': [], '저녁': [], '간식': []},
    );
    dailyLogs[date]![meal]?.add(log);
    saveToHive();  // 변경 시마다 저장
    notifyListeners();
  }

  int getTotalCalories(DateTime date) {
    if (!dailyLogs.containsKey(date)) return 0;
    return dailyLogs[date]!.values.fold(0, (sum, mealList) {
      return sum +
          mealList.fold(0, (mealSum, item) {
            return (mealSum + (item['calories'] ?? 0)).toInt();
          });
    });
  }

  void updateCalorieGoal(int newGoal) {
    calorieGoal = newGoal;
    saveToHive();
    notifyListeners();
  }

  // ─────────────────────────
  // 설문
  // ─────────────────────────
  void completeSurvey({
    required double currentW,
    required double targetW,
    required String name,
  }) {
    currentWeight = currentW;
    targetWeight = targetW;
    userName = name;
    isSurveyDone = true;
    saveToHive();
    notifyListeners();
  }

  // 설정 페이지 등에서 userName, targetWeight 변경
  void updateUserInfo({String? newName, double? newTarget}) {
    if (newName != null) userName = newName;
    if (newTarget != null) targetWeight = newTarget;
    saveToHive();
    notifyListeners();
  }
}
