import 'package:flutter/material.dart';
import 'calendar_view.dart';
import 'dashboard_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('식단 관리'),
          bottom: TabBar(
            tabs: [
              Tab(text: '달력'),
              Tab(text: '대시보드'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            CalendarView(),
            DashboardView(),
          ],
        ),
      ),
    );
  }
}
