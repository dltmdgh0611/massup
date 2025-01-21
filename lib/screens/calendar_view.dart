import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_state.dart';
import 'day_view.dart';

class CalendarView extends StatefulWidget {
  @override
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: true);

    // 현재 달의 1일
    DateTime firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    // 이번 달이 며칠까지 있는지
    int daysInMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
    // 이번 달 1일의 요일 (월=1 ... 일=7)
    int startWeekday = firstDayOfMonth.weekday;

    return Column(
      children: [
        // 월 변경 버튼
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    selectedDate = DateTime(selectedDate.year, selectedDate.month - 1, 1);
                  });
                },
              ),
              Text(
                '${selectedDate.year}년 ${selectedDate.month}월',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: () {
                  setState(() {
                    selectedDate = DateTime(selectedDate.year, selectedDate.month + 1, 1);
                  });
                },
              ),
            ],
          ),
        ),
        // 요일 헤더
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['월', '화', '수', '목', '금', '토', '일']
              .map((day) => Expanded(child: Center(child: Text(day))))
              .toList(),
        ),
        // 달력 Grid
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
            itemCount: daysInMonth + startWeekday - 1,
            itemBuilder: (context, index) {
              // 시작 요일 전까지는 빈 칸
              if (index < startWeekday - 1) {
                return SizedBox.shrink();
              }

              // 그리드 인덱스에서 실제 날짜 계산
              DateTime date = DateTime(
                selectedDate.year,
                selectedDate.month,
                index - startWeekday + 2,
              );

              return GestureDetector(
                onTap: () {
                  // 날짜별 DayView 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DayView(date: date),
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${date.day}'),
                      Text(
                        '${appState.getTotalCalories(date)}kcal',
                        style: TextStyle(fontSize: 12, color: Colors.green),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
