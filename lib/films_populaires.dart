import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'MoviesDetails.dart';
import 'series_populaires.dart';
import 'comics_populaires.dart';
import 'recherche.dart';
import 'main.dart';
import 'package:comics/blocs/Movie.dart';

class FilmsPopulairesScreen extends StatefulWidget {
  @override
  _FilmsPopulairesScreenState createState() => _FilmsPopulairesScreenState();
}

class _FilmsPopulairesScreenState extends State<FilmsPopulairesScreen> {
  List<dynamic> movies = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    final String apiKey = Config.comicVineApiKey;
    final String moviesEndpoint = 'movies';
    final String apiUrl =
        'https://comicvine.gamespot.com/api/$moviesEndpoint?api_key=$apiKey&format=json';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          movies = json.decode(response.body)['results'];
          isLoading = false;
        });
      } else {
        print('Erreur lors de la récupération des films: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la récupération des films: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF15232E),
        title: Text('Films les plus populaires'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: movies.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MoviesDetailsScreen(moviesDetails: movies[index]),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      color: Color(0xFF2D4455),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image à gauche
                          SizedBox(
                            width: 150,
                            height: 150,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                movies[index]['image']['medium_url'],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          // Espacement entre l'image et le texte
                          SizedBox(width: 8),
                          // Contenu à droite de l'image
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0, bottom: 14.0),
                                  child: Text(
                                    movies[index]['name'],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 4),
                                // Publisher
                                SizedBox(height: 4),
                                // Nombre d'épisodes
                                Row(
                                  children: [
                                    movies[index]['runtime'] != null ?
                                    Image.asset('assets/SVG/ic_movie_bicolor.png', width: 16, height: 16, color: Colors.grey[300]) :
                                    Container(),
                                    SizedBox(width: 4),
                                    Text(
                                      movies[index]['runtime'] != null ? '${movies[index]['runtime']}' : 'Nombre d\'épisodes inconnu',
                                      style: TextStyle(color: Colors.grey[300]),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                // Date d'ajout
                                Row(
                                  children: [
                                    movies[index]['release_date'] != null ?
                                    Image.asset('assets/SVG/ic_calendar_bicolor.png', width: 16, height: 16, color: Colors.grey[300]) :
                                    Container(),
                                    SizedBox(width: 4),
                                    Text(
                                      movies[index]['release_date'] != null ? movies[index]['release_date'] ?? '' : '',
                                      style: TextStyle(color: Colors.grey[300]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Tag orange en haut à gauche
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '#${index + 1}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF15233D),
        selectedItemColor: Color(0xFF56CCF2),
        unselectedItemColor: Colors.grey[400],
        currentIndex: 3, // Sélection de l'icône "Films" dans la BottomNavigationBar
        onTap: (int index) {
          if (index == 0) { // Accueil
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => EcranAccueil()), // Remplace l'écran actuel par l'écran d'accueil
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ComicsPopulairesScreen()), // Remplace l'écran actuel par l'écran des comics populaires
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SeriesPopulairesScreen()), // Remplace l'écran actuel par l'écran des séries populaires
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => FilmsPopulairesScreen()), // Remplace l'écran actuel par l'écran des films populaires
            );
          } else if (index == 4){
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SearchScreen()), // Remplace l'écran actuel par l'écran de recherche
            );
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/SVG/navbar_home.png',
              width: 24,
              height: 24,
              color: Colors.grey[400],
            ),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/SVG/navbar_comics.png',
              width: 24,
              height: 24,
              color: Colors.grey[400],
            ),
            label: 'Comics',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
                'assets/SVG/navbar_series.png',
                width: 24,
                height: 24,
                color: Colors.grey[400] // Couleur sélectionnée pour l'icône "Séries"
            ),
            label: 'Séries',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/SVG/navbar_movies.png',
              width: 24,
              height: 24,
              color: Color(0xFF56CCF2),
            ),
            label: 'Films',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/SVG/navbar_search.png',
              width: 24,
              height: 24,
              color: Colors.grey[400],
            ),
            label: 'Recherche',
          ),
        ],
      ),
    );
  }
}
