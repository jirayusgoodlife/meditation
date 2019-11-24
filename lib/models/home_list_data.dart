class MealsListData {
  String imagePath;
  String titleTxt;
  String startColor;
  String endColor;
  List<String> meals;
  int kacl;

  MealsListData({
    this.imagePath = '',
    this.titleTxt = '',
    this.startColor = "",
    this.endColor = "",
    this.meals,
    this.kacl = 0,
  });

  static List<MealsListData> tabIconsList = [
    MealsListData(
      imagePath: 'assets/fitness_app/breakfast.png',
      titleTxt: 'เสียงธรรมชาติ',
      kacl: 0,
      meals: [""],
      startColor: "#FA7D82",
      endColor: "#FFB295",
    ),
    MealsListData(
      imagePath: 'assets/fitness_app/lunch.png',
      titleTxt: 'เสียง',
      kacl: 0,
      meals: [""],
      startColor: "#738AE6",
      endColor: "#5C5EDD",
    ),
    MealsListData(
      imagePath: 'assets/fitness_app/snack.png',
      titleTxt: 'เสียง',
      kacl: 0,
      meals: [""],
      startColor: "#FE95B6",
      endColor: "#FF5287",
    ),
    MealsListData(
      imagePath: 'assets/fitness_app/dinner.png',
      titleTxt: 'Dinner',
      kacl: 0,
      meals: [""],
      startColor: "#6F72CA",
      endColor: "#1E1466",
    ),
  ];
}
