import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/mealModel.dart';

class MealService {
  static const String apiUrl =
      "https://www.themealdb.com/api/json/v1/1/search.php?s=";

  // Rastgele yemek için yeni endpoint
  static const String randomApiUrl =
      "https://www.themealdb.com/api/json/v1/1/random.php";

  static Future<List<Meal>> fetchMeals(String query) async {
    final response = await http.get(Uri.parse('$apiUrl$query'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Eğer "meals" null dönerse boş liste döndür
      if (data['meals'] == null) {
        return [];
      }

      final mealsJson = data['meals'] as List;
      return mealsJson.map((json) => Meal.fromJson(json)).toList();
    } else {
      throw Exception("Yemekler yüklenemedi!");
    }
  }

  // YENİ METOD: Rastgele yemek getir
  static Future<Meal?> fetchRandomMeal() async {
    try {
      final response = await http.get(Uri.parse(randomApiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Eğer "meals" null dönerse null döndür
        if (data['meals'] == null || data['meals'].isEmpty) {
          return null;
        }

        // İlk (ve tek) yemeği al
        return Meal.fromJson(data['meals'][0]);
      } else {
        throw Exception("Rastgele yemek yüklenemedi!");
      }
    } catch (e) {
      throw Exception("Rastgele yemek getirirken hata oluştu: $e");
    }
  }
}