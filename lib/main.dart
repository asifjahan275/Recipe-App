import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class Recipe {
  final String label;
  final String image;
  final List<String> ingredients;
  final List<String> instructions;

  Recipe({
    required this.label,
    required this.image,
    required this.ingredients,
    required this.instructions,
  });
}

class RecipeAPI {
  static Future<List<Recipe>> searchRecipes(String query) async {
    final response = await http.get(
        Uri.parse(
          'https://api.edamam.com/api/recipes/v2?app_key=91fba361c52986fcfd09242f1a23d0eb&co2EmissionsClass=A&_cont=CHcVQBtNNQphDmgVQntAEX4BY0t6AQcVX3cSVjdHN1FyBFAGQWZCBDMTYQR3DAVVEjdGVTQaNVB0URFqX3cWQT1OcV9xBB8VADQWVhFCPwoxXVZEITQeVDcBaR4-SQ%3D%3D&type=public&app_id=f8a801f5',
        ),
        headers: {
          'X-RapidAPI-Key':
          '40874c741fmsh5149195d1e27ce8p1ffb81jsn92d1e284efa0',
          'X-RapidAPI-Host': 'edamam-recipe-search.p.rapidapi.com'
        });
/*
    Map data = jsonDecode(response.body);
    data['hits'].forEach((e) {
      var hits;
      return hits.map((hit) {
        final Map<String, dynamic> recipeData = hit['recipe'];
        final List<dynamic> ingredients = recipeData['ingredientLines'];
        final List<dynamic> instructions = recipeData['instructions'] ?? [];
        return Recipe(
          label: recipeData['label'],
          image: recipeData['image'],
          ingredients: List<String>.from(ingredients),
          instructions: List<String>.from(instructions),
        );
      }).toList();


    });
*/

/*
      @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getApiData();
  }
*/
    // ignore: avoid_print
    print("check status code :------------------------------------");
    // ignore: avoid_print
    print(response.statusCode);
    try {
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> hits = data['hits'];
        return hits.map((hit) {
          final Map<String, dynamic> recipeData = hit['recipe'];
          final List<dynamic> ingredients = recipeData['ingredientLines'];
          final List<dynamic> instructions = recipeData['instructions'] ?? [];
          return Recipe(
            label: recipeData['label'],
            image: recipeData['image'],
            ingredients: List<String>.from(ingredients),
            instructions: List<String>.from(instructions),
          );
        }).toList();
      } else {
        // ignore: avoid_print
        print(response.statusCode.toString());
        throw Exception('Failed to load recipes ${response.statusCode}');
      }
    } catch (e) {
      //print(e);
      rethrow;
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Recipe App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SearchResultsPage(),
    );
  }
}

///
class SearchResultsPage extends StatefulWidget {
  const SearchResultsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SearchResultsPageState createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  // ignore: unused_field
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Recipe>> searchResults;

  @override
  void initState() {
    super.initState();
    searchResults =
        RecipeAPI.searchRecipes('chicken'); // Initial query for demonstration
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        // ignore: avoid_unnecessary_containers
        leading: Container(
          child: Image.network(
            'https://rapidapi-prod-apis.s3.amazonaws.com/1b/52f86c8f8b4d7a97b45c43a73b8471/c420eade44ce287a22344dadb2529c51.png',
            fit: BoxFit.cover,
          ),
        ),
        title: Container(
          alignment: Alignment.center,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                  onPressed: () => _searchController.clear(),
                  icon: const Icon(Icons.clear)),
              /*suffixIcon: IconButton(
                    onPressed: () => _searchController.clear(),
                    icon: Icon(Icons.clear),
                  ),*/

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50.0),
                //borderRadius: BorderRadius.circular(50),
              ),
              fillColor: Colors.white.withOpacity(0.3),
              filled: true,
              hintText: 'Search...',
              hintStyle: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        ),
        actions: [
          Icon(
            Icons.menu,
            size: 45,
            color: Colors.grey.withOpacity(0.4),
          )
        ],
        //title: const Text('Search Results'),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<List<Recipe>>(
          future: searchResults,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final recipes = snapshot.data!;
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16),
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RecipeDetailsPage(recipe: recipes[index]),
                        ),
                      );
                    },
                    child: RecipeCard(recipe: recipes[index]),
                  );
                },
              );
            } else {
              return const Center(child: Text('No recipes found.'));
            }
          },
        ),
      ),
    );
  }
}

class RecipeCard extends StatelessWidget {
  final Recipe recipe;

  const RecipeCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(recipe.image),
          const SizedBox(height: 8),
          Text(recipe.label),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeDetailsPage(recipe: recipe),
                ),
              );
            },
            child: const Text('View Details'),
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////
class RecipeDetailsPage extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailsPage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(recipe.image),
            const SizedBox(height: 16),
            Text(recipe.label,
                style:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Ingredients:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: recipe.ingredients
                  .map((ingredient) => Text('- $ingredient'))
                  .toList(),
            ),
            const SizedBox(height: 16),
            const Text('Instructions:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: recipe.instructions
                  .map((instruction) => Text(instruction))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
/*
class Model {
  String? image, url, source, label
      //shareAs,
      //yield,
      //dietLabels,
      //healthLabels,
      //cautions,
      //ingredientLines
      ;
  Model({this.image, this.url, this.source, this.label
      //this.yield,
      //this.dietLabels,
      //this.cautions,
      //this.healthLabels,
      //this.ingredientLines,
      //this.shareAs
      });
}
*/
