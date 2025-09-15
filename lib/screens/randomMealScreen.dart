import 'package:flutter/material.dart';
import '../model/mealModel.dart';
import '../service/mealService.dart';
import 'favoriteScreen.dart';

class RandomMealScreen extends StatefulWidget {
  const RandomMealScreen({super.key});

  @override
  _RandomMealScreenState createState() => _RandomMealScreenState();
}

class _RandomMealScreenState extends State<RandomMealScreen> {
  Future<Meal?>? _randomMeal;

  @override
  void initState() {
    super.initState();
    _getRandomMeal();
  }

  void _getRandomMeal() {
    setState(() {
      _randomMeal = MealService.fetchRandomMeal();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Günün Yemeği",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 27),),
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
        actions: [
          // Sağ üst köşede favori butonu
          FutureBuilder<Meal?>(
            future: _randomMeal,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final meal = snapshot.data!;
                return StatefulBuilder(
                  builder: (context, setState) {
                    return IconButton(
                      icon: Icon(
                        FavoriteManager.isFavorite(meal.id ?? "")
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        setState(() {
                          FavoriteManager.toggleFavorite(meal);
                        });
                      },
                    );
                  },
                );
              }
              // Yemek yüklenene kadar boş bir Container göster
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: FutureBuilder<Meal?>(
        future: _randomMeal,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Rastgele yemek getiriliyor..."),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 80, color: Colors.red),
                  const SizedBox(height: 16),
                  Text("Hata: ${snapshot.error}"),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _getRandomMeal,
                    child: const Text("Tekrar Dene"),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text("Rastgele yemek bulunamadı"));
          }

          final meal = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Başlık sola hizalı
              children: [
                if (meal.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      meal.imageUrl!,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image_not_supported, size: 200),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  meal.name ?? "Bilinmeyen Yemek",
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "${meal.category ?? "Kategori yok"} • ${meal.area ?? "Bölge yok"}",
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _getRandomMeal,
                    icon: const Icon(Icons.shuffle),
                    label: const Text("Yeni Yemek"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Tarif:",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  meal.instructions ?? "Tarif bulunamadı.",
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Malzemeler:",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: meal.ingredients.length,
                  itemBuilder: (context, index) {
                    final ingredient = meal.ingredients[index];
                    final measure = meal.measures[index];
                    if (ingredient == null || ingredient.isEmpty) {
                      return const SizedBox();
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        "• $ingredient - ${measure ?? ""}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}