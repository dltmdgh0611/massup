class FoodItem {
  final String name;       // 음식 이름
  final int calories;      // 칼로리
  final int carbs;         // 탄수화물
  final int protein;       // 단백질
  final int fat;           // 지방

  FoodItem({
    required this.name,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
  });
}

// 실제로는 DB나 API 연동을 해야 함.
// 여기서는 예시로 몇 가지 아이템만
final List<FoodItem> dummyFoodDatabase = [
  FoodItem(name: '삼각김밥(참치마요)', calories: 180, carbs: 32, protein: 4, fat: 3),
  FoodItem(name: '샌드위치(에그마요)', calories: 350, carbs: 40, protein: 13, fat: 15),
  FoodItem(name: '컵라면(신라면)', calories: 500, carbs: 80, protein: 8, fat: 16),
  FoodItem(name: '도시락(치킨가슴살)', calories: 420, carbs: 45, protein: 25, fat: 15),
  FoodItem(name: '닭가슴살', calories: 200, carbs: 2, protein: 40, fat: 4),
  FoodItem(name: '스파게티(토마토)', calories: 510, carbs: 70, protein: 18, fat: 15),
  // ... 편의점 음식, 마트 음식 등 더 추가
];

/// 검색 로직 (간단 문자열 포함 여부)
List<FoodItem> searchFoodDatabase(String query) {
  // query를 소문자로 변환해 포함 여부 확인
  final lowerQuery = query.toLowerCase();
  return dummyFoodDatabase.where((food) {
    return food.name.toLowerCase().contains(lowerQuery);
  }).toList();
}
