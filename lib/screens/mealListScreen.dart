import 'package:flutter/material.dart';
import '../model/mealModel.dart';
import '../service/mealService.dart';
import 'favoriteScreen.dart';

class MealListScreen extends StatefulWidget {
  const MealListScreen({super.key});

  @override
  _MealListScreenState createState() => _MealListScreenState();
}

class _MealListScreenState extends State<MealListScreen> {
  late Future<List<Meal>> _futureMeals;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _futureMeals = MealService.fetchMeals('');
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _futureMeals = MealService.fetchMeals(_searchController.text);
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _futureMeals = MealService.fetchMeals('');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tadında'ya Hoşgeldin",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 27),),
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

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Yemek Ara',
                hintText: 'Yemek adı girin...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Meal>>(
              future: _futureMeals,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Hata: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Yemek bulunamadı"));
                }

                final meals = snapshot.data!;
                return ListView.builder(
                  itemCount: meals.length,
                  itemBuilder: (context, index) {
                    final meal = meals[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MealDetailScreen(meal: meal),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10, left: 10, top: 6, bottom: 6),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: const Border(
                              left: BorderSide(color: Colors.orange, width: 3),
                              right: BorderSide(color: Colors.orange, width: 3),
                            ),
                          ),
                          child: Card(
                            margin: EdgeInsets.zero,
                            child: ListTile(
                              leading: Container(
                                  width: 100,
                                  height: 100,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      meal.imageUrl ?? "",
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Icon(
                                        Icons.image_not_supported,
                                        size: 50,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ),
                                ),
                              title: Text(
                                meal.name ?? "İsimsiz Yemek",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(meal.category ?? "Kategori yok"),
                               trailing:  IconButton(
                                  icon: Icon(
                                    FavoriteManager.isFavorite(meal.id ?? "")
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      FavoriteManager.toggleFavorite(meal);
                                    });
                                  },
                                ),

                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}




class MealDetailScreen extends StatelessWidget {
  final Meal meal;

  const MealDetailScreen({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(meal.name ?? "Yemek Detayı"),
        backgroundColor: Colors.orange,
        actions: [
          StatefulBuilder(
            builder: (context, setState) {
              return IconButton(
                icon: Icon(
                  FavoriteManager.isFavorite(meal.id ?? "")
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: Colors.red,
                ),
                onPressed: () {
                  setState(() {
                    FavoriteManager.toggleFavorite(meal);
                  });
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "${meal.category ?? "Kategori yok"} • ${meal.area ?? "Bölge yok"}",
              style: const TextStyle(color: Colors.grey, fontSize: 16),
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
                if (ingredient == null || ingredient.isEmpty)
                  return const SizedBox();
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
      ),
    );
  }
}
