// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app_state.dart';
import 'screens/bottom_nav_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/survey_wizard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ko_KR 날짜 형식을 사용하려면 이렇게 초기화해줘야 한다
  await initializeDateFormatting('ko_KR', null);
  // (1) Hive 초기화
  await Hive.initFlutter();

  // (2) Box 열기 (예: "myBox")
  // 이 Box를 전역에서 쓰기 위해, 보통 singleton 패턴 또는 Provider로 감싸줌
  final box = await Hive.openBox('myBox');

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(box),
      child: MyApp(box : box),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Box box;
  const MyApp({Key? key, required this.box}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // (3) AppState 생성 시 Hive Box를 인자로 넘김
    return ChangeNotifierProvider(
      create: (_) => AppState(box),
      child: Consumer<AppState>(
        builder: (context, appState, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData.dark().copyWith(
              primaryColor: Colors.green,
              scaffoldBackgroundColor: Colors.black,
              appBarTheme: AppBarTheme(backgroundColor: Colors.black),
              floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: Colors.green),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green,
                  side: BorderSide(color: Colors.green),
                ),
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(foregroundColor: Colors.green),
              ),
              inputDecorationTheme: InputDecorationTheme(
                labelStyle: TextStyle(color: Colors.green),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 2),
                ),
              ),
            ),
            // (4) 설문 완료 여부에 따라 초기 화면 결정
            home: appState.isSurveyDone ? BottomNavScreen() : SurveyWizard(),
          );
        },
      ),
    );
  }
}