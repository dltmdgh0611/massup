import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../../app_state.dart';

class DayView extends StatefulWidget {
  final DateTime date;

  const DayView({Key? key, required this.date}) : super(key: key);

  @override
  _DayViewState createState() => _DayViewState();
}

class _DayViewState extends State<DayView> {
  // db.json에서 로드한 식품 리스트
  List<Map<String, dynamic>> _foodsDb1 = [];
  // db2.json에서 로드한 식품 리스트
  List<Map<String, dynamic>> _foodsDb2 = [];

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  /// 두 개의 JSON 파일(db.json / db2.json)에서 데이터를 로드
  Future<void> _loadFoods() async {
    // 1) db.json
    final jsonString1 = await rootBundle.loadString('assets/db.json');
    final List<dynamic> jsonData1 = json.decode(jsonString1);
    final foods1 =
    jsonData1.map((item) => item as Map<String, dynamic>).toList();

    // 2) db2.json
    final jsonString2 = await rootBundle.loadString('assets/db2.json');
    final List<dynamic> jsonData2 = json.decode(jsonString2);
    final foods2 =
    jsonData2.map((item) => item as Map<String, dynamic>).toList();

    setState(() {
      _foodsDb1 = foods1;
      _foodsDb2 = foods2;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    // 해당 날짜에 대한 기본 카테고리가 없으면 생성
    appState.dailyLogs.putIfAbsent(
      widget.date,
          () => {'아침': [], '점심': [], '저녁': [], '간식': []},
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.date.year}-${widget.date.month}-${widget.date.day} 식단'),
      ),
      body: ListView(
        children: appState.dailyLogs[widget.date]!.keys.map((meal) {
          final mealLogs = appState.dailyLogs[widget.date]![meal] ?? [];

          return ExpansionTile(
            // 아침/점심/저녁/간식 섹션을 초록색으로
            title: Text(meal),
            initiallyExpanded: true,  // 처음부터 펼쳐진 상태
            textColor: Colors.green,
            iconColor: Colors.green,
            collapsedTextColor: Colors.green,
            collapsedIconColor: Colors.green,

            children: [
              // (1) 이미 등록된 항목 표시
              ...mealLogs.asMap().entries.map((entry) {
                final idx = entry.key;
                final log = entry.value;
                final itemName = log['name'] ?? '';
                final itemCal = log['calories'] ?? 0;
                final itemCarb = log['carbs'] ?? 0;
                final itemProtein = log['protein'] ?? 0;
                final itemFat = log['fat'] ?? 0;

                return ListTile(
                  title: Text(
                    '$itemName ${itemCal} kcal '
                        '(탄 $itemCarb / 단 $itemProtein / 지 $itemFat)',
                  ),
                  onTap: () {
                    // 수정 다이얼로그
                    _showEditDialog(
                      context: context,
                      appState: appState,
                      meal: meal,
                      index: idx,
                      initName: itemName,
                      initCal: itemCal,
                      initCarbs: itemCarb,
                      initProtein: itemProtein,
                      initFat: itemFat,
                    );
                  },
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      appState.dailyLogs[widget.date]![meal]!.removeAt(idx);
                      appState.notifyListeners();
                    },
                  ),
                );
              }).toList(),

              // (2) 새 항목 추가 버튼
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      _showAddDialog(context, appState, meal);
                    },
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // (A) 새 항목 추가: 검색(자동완성) 기능
  // ─────────────────────────────────────────────
  void _showAddDialog(
      BuildContext context,
      AppState appState,
      String meal,
      ) {
    final nameController = TextEditingController();
    final calController = TextEditingController();
    final carbController = TextEditingController();
    final proteinController = TextEditingController();
    final fatController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$meal 추가'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // (A-1) 검색 자동완성
              TypeAheadField<Map<String, dynamic>?>(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: nameController,
                  decoration: InputDecoration(labelText: '이름'),
                ),
                suggestionsCallback: (pattern) {
                  if (pattern.isEmpty) return [];

                  final lower = pattern.toLowerCase();

                  // 1) db2에서 검색
                  final matchesDb2 = _foodsDb2.where((food) {
                    final foodName = (food['식품명'] ?? food['name'] ?? '')
                        .toString()
                        .toLowerCase();
                    return foodName.contains(lower);
                  }).toList();

                  // 한 개만 상단에 표시
                  Map<String, dynamic>? topDb2Item;
                  if (matchesDb2.isNotEmpty) {
                    topDb2Item = matchesDb2.first;
                  }

                  // 2) db1 검색
                  final matchesDb1 = _foodsDb1.where((food) {
                    final foodName = (food['식품명'] ?? food['name'] ?? '')
                        .toString()
                        .toLowerCase();
                    return foodName.contains(lower);
                  }).toList();

                  final results = <Map<String, dynamic>>[];

                  // db2의 첫 항목(있는 경우)만 맨 위에
                  if (topDb2Item != null) {
                    // 'fromDb2': true → 초록색 강조용 플래그
                    topDb2Item = {
                      ...topDb2Item,
                      'fromDb2': true,
                    };
                    results.add(topDb2Item);
                  }

                  // 이어서 db1 결과
                  results.addAll(matchesDb1);

                  return results;
                },
                itemBuilder: (context, Map<String, dynamic>? suggestion) {
                  if (suggestion == null) return SizedBox();
                  final name = suggestion['식품명'] ?? suggestion['name'] ?? '';
                  final cal = suggestion['칼로리'] ?? suggestion['calories'] ?? 0;
                  final carb = suggestion['탄수화물'] ?? suggestion['carbs'] ?? 0;
                  final prot = suggestion['단백질'] ?? suggestion['protein'] ?? 0;
                  final fat = suggestion['지방'] ?? suggestion['fat'] ?? 0;

                  // 분류 or 제조사명
                  final category = suggestion['분류'] ?? suggestion['제조사명'] ?? '';

                  // db2에서 왔는지 체크
                  final bool isFromDb2 = suggestion['fromDb2'] == true;
                  final textColor = isFromDb2 ? Colors.green : Colors.white;

                  return ListTile(
                    title: Text(
                      '$name',
                      style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '$category\n${cal}kcal (탄 $carb / 단 $prot / 지 $fat)',
                      style: TextStyle(fontSize: 12),
                    ),
                  );
                },
                onSuggestionSelected: (Map<String, dynamic>? suggestion) {
                  if (suggestion == null) return;
                  final name = suggestion['식품명'] ?? suggestion['name'] ?? '';
                  final cal = suggestion['칼로리'] ?? suggestion['calories'] ?? 0;
                  final carb = suggestion['탄수화물'] ?? suggestion['carbs'] ?? 0;
                  final prot = suggestion['단백질'] ?? suggestion['protein'] ?? 0;
                  final fat = suggestion['지방'] ?? suggestion['fat'] ?? 0;

                  nameController.text = name.toString();
                  calController.text = cal.toString();
                  carbController.text = carb.toString();
                  proteinController.text = prot.toString();
                  fatController.text = fat.toString();
                },
              ),

              // (A-2) 직접 입력 칼로리/탄/단/지
              TextField(
                controller: calController,
                decoration: InputDecoration(labelText: '칼로리'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: carbController,
                decoration: InputDecoration(labelText: '탄수화물'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: proteinController,
                decoration: InputDecoration(labelText: '단백질'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: fatController,
                decoration: InputDecoration(labelText: '지방'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final newName = nameController.text.trim();
              final newCal = double.tryParse(calController.text) ?? 0.0;
              final newCarb = double.tryParse(carbController.text) ?? 0.0;
              final newProtein = double.tryParse(proteinController.text) ?? 0.0;
              final newFat = double.tryParse(fatController.text) ?? 0.0;

              if (newName.isNotEmpty) {
                appState.updateLog(
                  widget.date,
                  meal,
                  {
                    'name': newName,
                    'calories': newCal,
                    'carbs': newCarb,
                    'protein': newProtein,
                    'fat': newFat,
                  },
                );
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
  }

  // ─────────────────────────────────────────────
  // (B) 항목 수정 다이얼로그
  // ─────────────────────────────────────────────
  void _showEditDialog({
    required BuildContext context,
    required AppState appState,
    required String meal,
    required int index,
    required String initName,
    required double initCal,
    required double initCarbs,
    required double initProtein,
    required double initFat,
  }) {
    final nameController = TextEditingController(text: initName);
    final calController = TextEditingController(text: '$initCal');
    final carbController = TextEditingController(text: '$initCarbs');
    final proteinController = TextEditingController(text: '$initProtein');
    final fatController = TextEditingController(text: '$initFat');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('$meal 수정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: '이름'),
            ),
            TextField(
              controller: calController,
              decoration: InputDecoration(labelText: '칼로리'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: carbController,
              decoration: InputDecoration(labelText: '탄수화물'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: proteinController,
              decoration: InputDecoration(labelText: '단백질'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: fatController,
              decoration: InputDecoration(labelText: '지방'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final newName = nameController.text.trim();
              final newCal = double.tryParse(calController.text) ?? 0.0;
              final newCarb = double.tryParse(carbController.text) ?? 0.0;
              final newProtein = double.tryParse(proteinController.text) ?? 0.0;
              final newFat = double.tryParse(fatController.text) ?? 0.0;

              // 항목 갱신
              appState.dailyLogs[widget.date]![meal]![index] = {
                'name': newName,
                'calories': newCal,
                'carbs': newCarb,
                'protein': newProtein,
                'fat': newFat,
              };
              appState.notifyListeners();
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
  }
}
