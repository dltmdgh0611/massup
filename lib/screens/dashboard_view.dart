import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../../app_state.dart';

class DashboardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: true);

    // "오늘" 날짜
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 막대그래프용 - 1/20 ~ 1/26
    final List<DateTime> weekDates = List.generate(7, (i) {
      return DateTime(2025, 1, 20 + i);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('${appState.userName} 님,\n오늘 목표 칼로리까지 ${appState.calorieGoal - appState.getTotalCalories(today)}kcal 남았어요.'),
      ),
      body: Column(
        children: [
          // (1) 원형 그래프 영역을 고정 높이로 지정 → 작게 표시
          Container(
            height: 220, // 원하는 높이로 조절
            child: GestureDetector(
              onTap: () {
                final goalController = TextEditingController(
                  text: appState.calorieGoal.toString(),
                );
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('목표 칼로리 설정'),
                    content: TextField(
                      controller: goalController,
                      decoration: InputDecoration(labelText: '목표 칼로리'),
                      keyboardType: TextInputType.number,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          final newGoal = int.tryParse(goalController.text);
                          if (newGoal != null) {
                            appState.updateCalorieGoal(newGoal);
                          }
                          Navigator.pop(context);
                        },
                        child: Text('저장'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('취소'),
                      ),
                    ],
                  ),
                );
              },
              child: SfCircularChart(
                backgroundColor: Colors.transparent,
                annotations: [
                  CircularChartAnnotation(
                    widget: Text(
                      '${appState.getTotalCalories(today)} / ${appState.calorieGoal} kcal',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                series: <CircularSeries>[
                  DoughnutSeries(
                    dataSource: [
                      {
                        'category': '섭취',
                        'value': appState.getTotalCalories(today),
                      },
                      {
                        'category': '남음',
                        'value': appState.calorieGoal
                            - appState.getTotalCalories(today),
                      },
                    ],
                    xValueMapper: (data, _) => data['category'],
                    yValueMapper: (data, _) => data['value'],
                    innerRadius: '70%',
                    // 섭취: 초록색, 남음: 밝은 회색
                    pointColorMapper: (data, _) {
                      if (data['category'] == '섭취') {
                        return Colors.green;
                      } else {
                        return Colors.white70;
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          // (2) 막대 그래프는 Expanded → 남은 공간을 대부분 차지
          Expanded(
            child: SfCartesianChart(
              backgroundColor: Colors.transparent,
              primaryXAxis: CategoryAxis(),
              title: ChartTitle(text: '1/20 ~ 1/26 칼로리 섭취'),
              series: <ChartSeries>[
                // "섭취" 하나만 표시
                ColumnSeries(
                  dataSource: weekDates.map((date) => {
                    'date': date,
                    'calories': appState.getTotalCalories(date),
                  }).toList(),
                  xValueMapper: (data, _) {
                    final d = data['date'] as DateTime;
                    return DateFormat('M/d (E)', 'ko_KR').format(d);
                  },
                  yValueMapper: (data, _) => data['calories'],
                  name: '섭취',
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
