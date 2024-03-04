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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSeries();
    fetchComics();
  }

  Future<void> fetchSeries() async {
    final String apiKey = Config.comicVineApiKey;
    final String seriesEndpoint = 'series_list'; // Endpoint for series
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
    final String comicsEndpoint = 'movies_list'; // Endpoint for comics
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('Bienvenue !'),
            Flexible(
              child: Image.asset('assets/SVG/astronaut.svg', width: 10, height: 10),
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
              child: Text(
                'Séries populaires',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: series.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 120,
                      color: Color(0xFF1E3243),
                      child: Center(
                        child: Text(
                          series[index]['name'],
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Comics populaires',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: comics.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 120,
                      color: Color(0xFF1E3243),
                      child: Center(
                        child: Text(
                          comics[index]['name'],
                          style: TextStyle(color: Colors.white),
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
        backgroundColor: Color(0xFF0F1E2B),
        selectedItemColor: Color(0xFF56CCF2), // Couleur bleue plus claire pour les boutons sélectionnés
        unselectedItemColor: Color(0xFF778BA8),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Comics'),
          BottomNavigationBarItem(icon: Icon(Icons.tv), label: 'Séries'),
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Films'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Recherche'),
        ],
      ),
    );
  }
}
