class Meal {
  final String? id;
  final String? name;
  final String? category;
  final String? area;
  final String? instructions;
  final String? imageUrl;
  final List<String?> ingredients;
  final List<String?> measures;

  Meal({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.instructions,
    required this.imageUrl,
    required this.ingredients,
    required this.measures,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    List<String?> ingredients = [];
    List<String?> measures = [];

    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i']as String?;
      final measure = json['strMeasure$i']as String?;

      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
        ingredients.add(ingredient.toString());
        measures.add(measure != null ? measure.toString() : '');
      }
    }

    return Meal(
      id: json['idMeal']as String?,
      name: json['strMeal']as String?,
      category: json['strCategory']as String?,
      area: json['strArea']as String?,
      instructions: json['strInstructions']as String?,
      imageUrl: json['strMealThumb']as String?,
      ingredients: ingredients,
      measures: measures,
    );
  }
}
