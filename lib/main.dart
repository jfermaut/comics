import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'config.dart';

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
      home: EcranAcceuil(),
    );
  }
}

class EcranAcceuil extends StatefulWidget {
  @override
  _EcranAcceuilState createState() => _EcranAcceuilState();
}

class _EcranAcceuilState extends State<EcranAcceuil> {
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
          isLoading = false;
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
        backgroundColor: Color(0xFF15232E), // Couleur de fond de l'app bar
        title: Row(
          children: [
            Text('Bienvenue !'),
            Spacer(),
            SizedBox(height: 20),
            Flexible(
              child: Image.asset('assets/SVG/astronaut.png', width: 150, height: 150),
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(Icons.circle, color: Colors.orange, size: 10),
                  SizedBox(width: 5),
                  Text(
                    'Séries populaires',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Container(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: series.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        width: 180,
                        height: 200,
                        color: Color(0xFF1E3243),
                        child: Column(
                          children: [
                            Image.network(
                              series[index]['image']['medium_url'],
                              width: 180,
                              height: 160,
                              fit: BoxFit.cover,
                            ),
                            Text(
                              series[index]['name'],
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(Icons.circle, color: Colors.orange, size: 10),
                  SizedBox(width: 5),
                  Text(
                    'Comics populaires',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Container(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: comics.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        width: 180,
                        height: 200,
                        color: Color(0xFF1E3243),
                        child: Column(
                          children: [
                            Image.network(
                              comics[index]['image']['medium_url'],
                              width: 180,
                              height: 160,
                              fit: BoxFit.cover,
                            ),
                            Text(
                              comics[index]['name'],
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(Icons.circle, color: Colors.orange, size: 10),
                  SizedBox(width: 5),
                  Text(
                    'Films populaires',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Container(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        width: 180,
                        height: 200,
                        color: Color(0xFF1E3243),
                        child: Column(
                          children: [
                            Image.network(
                              movies[index]['image']['medium_url'],
                              width: 180,
                              height: 160,
                              fit: BoxFit.cover,
                            ),
                            Text(
                              movies[index]['name'],
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF15232E), // Nouvelle couleur pour la barre de navigation
        selectedItemColor: Color(0xFF56CCF2),
        unselectedItemColor: Colors.grey[400],
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
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
    );
  }
}
