import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'SerieDetails.dart';
import 'MoviesDetails.dart';
import 'comicsDetails.dart';
import 'config.dart';
import 'series_populaires.dart';
import 'films_populaires.dart';
import 'comics_populaires.dart';
import 'recherche.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mon App',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF15232E),
      ),
      home: EcranAccueil(),
    );
  }
}

class EcranAccueil extends StatefulWidget {
  @override
  _EcranAccueilState createState() => _EcranAccueilState();
}

class _EcranAccueilState extends State<EcranAccueil> {
  List<dynamic> series = [];
  List<dynamic> comics = [];
  List<dynamic> movies = [];
  bool isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchSeries();
    fetchComics();
    fetchMovies();
  }

  Future<void> fetchSeries() async {
    final String apiKey = Config.comicVineApiKey;
    final String seriesEndpoint = 'series_list';
    final String apiUrl =
        'https://comicvine.gamespot.com/api/$seriesEndpoint?api_key=$apiKey&format=json';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          series = json.decode(response.body)['results'];
          isLoading = false;
        });
      } else {
        print('Erreur lors de la récupération des séries: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la récupération des séries: $e');
    }
  }

  Future<void> fetchComics() async {
    final String apiKey = Config.comicVineApiKey;
    final String comicsEndpoint = 'issues';
    final String apiUrl =
        'https://comicvine.gamespot.com/api/$comicsEndpoint?api_key=$apiKey&format=json';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          comics = json.decode(response.body)['results'];
        });
      } else {
        print('Erreur lors de la récupération des comics: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la récupération des comics: $e');
    }
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
        backgroundColor: Color(0xFF15232E), // Couleur de fond de l'app bar
        title: Row(
          children: [
            Text('Bienvenue !'),
            Spacer(),
            SizedBox(height: 20),
            Flexible(
              child: Image.asset(
                'assets/SVG/astronaut.png',
                width: 150,
                height: MediaQuery.of(context).size.height * 0.3, // Taille relative à la hauteur de l'écran
              ),
            ),
          ],
        ),
        leading: Container(),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Container(
              margin: EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                color: Color(0xFF1E3243),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.circle, color: Colors.orange, size: 10),
                        SizedBox(width: 5),
                        Text(
                          'Séries populaires',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Spacer(),
                        // Bouton "Voir plus"
                        Container(
                          width: 80,
                          height: 35,
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SeriesPopulairesScreen()),
                              );
                            },
                            child: Text(
                              'Voir plus',
                              style: TextStyle(fontSize: 12, color: Colors.white), // Couleur du texte en blanc
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 250,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: series.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                              onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SerieDetailsScreen(
                                  apiDetailUrl: series[index]['api_detail_url'],
                                ),
                              ),
                            );
                          },
                          child:  Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Container(
                                width: 180,
                                height: 200,
                                color: Color(0xFF2D4455),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image.network(
                                      series[index]['image']['medium_url'],
                                      width: 180,
                                      height: 160,
                                      fit: BoxFit.cover,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      series[index]['name'],
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              margin: EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                color: Color(0xFF1E3243),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.circle, color: Colors.orange, size: 10),
                        SizedBox(width: 5),
                        Text(
                          'Comics populaires',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Spacer(),
                        // Bouton "Voir plus"
                        Container(
                          width: 80,
                          height: 35,
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ComicsPopulairesScreen()),
                              );
                            },
                            child: Text(
                              'Voir plus',
                              style: TextStyle(fontSize: 12, color: Colors.white), // Couleur du texte en blanc
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 250,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: comics.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ComicsDetailsScreen(
                                      apiDetailUrl: comics[index]['api_detail_url'],
                                    ),
                                  ),
                                );
                              },
                          child:  Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Container(
                                width: 180,
                                height: 200,
                                color: Color(0xFF2D4455),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    comics[index]['image'] != null && comics[index]['image']['medium_url'] != null
                                        ? Image.network(
                                      comics[index]['image']['medium_url'],
                                      width: 180,
                                      height: 160,
                                      fit: BoxFit.cover,
                                    )
                                        : Container(), // Placeholder ou indication d'image manquante
                                    SizedBox(height: 8),
                                    Text(
                                      comics[index]['volume']['name'] ?? 'Titre inconnu', // Utilise un titre par défaut si 'name' est null
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],

                                ),
                              ),
                            ),
                          ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              margin: EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                color: Color(0xFF1E3243),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.circle, color: Colors.orange, size: 10),
                        SizedBox(width: 5),
                        Text(
                          'Films populaires',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Spacer(),
                        // Bouton "Voir plus"
                        Container(
                          width: 80,
                          height: 35,
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => FilmsPopulairesScreen()),
                              );
                            },
                            child: Text(
                              'Voir plus',
                              style: TextStyle(fontSize: 12, color: Colors.white), // Couleur du texte en blanc
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 250,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
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
                          child:  Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Container(
                                width: 180,
                                height: 200,
                                color: Color(0xFF2D4455),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image.network(
                                      movies[index]['image']['medium_url'],
                                      width: 180,
                                      height: 160,
                                      fit: BoxFit.cover,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      movies[index]['name'],
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Color(0xFF15233D),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          selectedItemColor: Color(0xFF56CCF2),
          unselectedItemColor: Colors.grey[400],
          currentIndex: 0,
          onTap: (int index) {
            if (index == 0) { // Accueil
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => EcranAccueil()), // Remplace l'écran actuel par l'écran d'accueil
              );
            } else if (index == 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ComicsPopulairesScreen()), // Remplace l'écran actuel par l'écran d'accueil
              );
            } else if (index == 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SeriesPopulairesScreen()), // Remplace l'écran actuel par l'écran d'accueil
              );
            } else if (index == 3) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => FilmsPopulairesScreen()), // Remplace l'écran actuel par l'écran d'accueil
              );
            } else if (index == 4){
              Navigator.pushReplacement(
                context,
                  MaterialPageRoute(builder: (context) => SearchScreen()),
              );
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/SVG/navbar_home.png',
                width: 24,
                height: 24,
                color: _selectedIndex == 0 ? Color(0xFF56CCF2) : Colors.grey[400],
              ),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/SVG/navbar_comics.png',
                width: 24,
                height: 24,
                color: _selectedIndex == 1 ? Color(0xFF56CCF2) : Colors.grey[400],
              ),
              label: 'Comics',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/SVG/navbar_series.png',
                width: 24,
                height: 24,
                color: _selectedIndex == 2 ? Color(0xFF56CCF2) : Colors.grey[400],
              ),
              label: 'Séries',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/SVG/navbar_movies.png',
                width: 24,
                height: 24,
                color: _selectedIndex == 3 ? Color(0xFF56CCF2) : Colors.grey[400],
              ),
              label: 'Films',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/SVG/navbar_search.png',
                width: 24,
                height: 24,
                color: _selectedIndex == 4 ? Color(0xFF56CCF2) : Colors.grey[400],
              ),
              label: 'Recherche',
            ),
          ],
        ),
      ),
    );
  }
}

