import 'package:flutter/material.dart';
import '../model/mealModel.dart';
import 'mealListScreen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  Widget build(BuildContext context) {
    final favoriteMeals = FavoriteManager.getFavorites();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Favori Yemeklerim",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 27),),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepOrange, Colors.orangeAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      body: favoriteMeals.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              "Henüz favori yemeğiniz yok",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              "Yemek listesinden favorilerinizi ekleyin",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: favoriteMeals.length,
        itemBuilder: (context, index) {
          final meal = favoriteMeals[index];
          return Padding(
            padding: const EdgeInsets.only(right: 10, left: 10, top: 5, bottom: 5),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: const Border(
                  left: BorderSide(color: Colors.red, width: 3),
                  right: BorderSide(color: Colors.red, width: 3),
                ),
              ),
              child: Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: Container(
                    width: 60,
                    height: 60,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        meal.imageUrl ?? "",
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.image_not_supported,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    meal.name ?? "İsimsiz Yemek",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(meal.category ?? "Kategori yok"),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        FavoriteManager.removeFavorite(meal.id ?? "");
                      });
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MealDetailScreen(meal: meal),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}



// Favoriler için basit bir yönetim sınıfı
class FavoriteManager {
  static final List<Meal> _favorites = [];

  static List<Meal> getFavorites() => List.unmodifiable(_favorites);

  static bool isFavorite(String mealId) {
    return _favorites.any((meal) => meal.id == mealId);
  }

  static void addFavorite(Meal meal) {
    if (!isFavorite(meal.id ?? "")) {
      _favorites.add(meal);
    }
  }

  static void removeFavorite(String mealId) {
    _favorites.removeWhere((meal) => meal.id == mealId);
  }

  static void toggleFavorite(Meal meal) {
    if (isFavorite(meal.id ?? "")) {
      removeFavorite(meal.id ?? "");
    } else {
      addFavorite(meal);
    }
  }
}
