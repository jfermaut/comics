import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';

import 'blocs/Series.dart';
import 'SerieDetails.dart';
import 'comics_populaires.dart';
import 'recherche.dart';
import 'films_populaires.dart';
import 'main.dart';

class SeriesPopulairesScreen extends StatefulWidget {
  @override
  _SeriesPopulairesScreenState createState() => _SeriesPopulairesScreenState();
}

class _SeriesPopulairesScreenState extends State<SeriesPopulairesScreen> {
  late Future<List<Series>> futureSeries;

  @override
  void initState() {
    super.initState();
    futureSeries = fetchSeries();
  }

  Future<List<Series>> fetchSeries({int limit = 100, int offset = 0}) async {
    final url = Uri.parse('https://comicvine.gamespot.com/api/series_list?api_key=${Config.comicVineApiKey}&format=json&limit=$limit&offset=$offset&field_list=id,name,image,publisher,count_of_episodes,start_year,api_detail_url');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = List<Map<String, dynamic>>.from(data['results']);
      return results.map((json) => Series.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load series');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF15232E),
        title: Text('Séries les plus populaires'),
      ),
      body: FutureBuilder<List<Series>>(
        future: futureSeries,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final series = snapshot.data![index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SerieDetailsScreen(
                          apiDetailUrl: series.apiDetailUrl,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      color: Color(0xFF2D4455),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 150,
                                  height: 150,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.network(
                                      series.imageUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        series.name,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Image.asset(
                                            'assets/SVG/ic_books_bicolor.png',
                                            width: 16,
                                            height: 16,
                                            color: Colors.grey[300],
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            series.publisher.isNotEmpty
                                                ? series.publisher
                                                : 'Année de début inconnue',
                                            style: TextStyle(
                                              color: Colors.grey[300],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Image.asset(
                                            'assets/SVG/ic_tv_bicolor.png',
                                            width: 16,
                                            height: 16,
                                            color: Colors.grey[300],
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            series.countOfEpisodes > 0
                                                ? '${series.countOfEpisodes}'
                                                : 'Nombre d\'épisodes inconnu',
                                            style: TextStyle(
                                              color: Colors.grey[300],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Image.asset(
                                            'assets/SVG/ic_calendar_bicolor.png',
                                            width: 16,
                                            height: 16,
                                            color: Colors.grey[300],
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            series.startYear.isNotEmpty
                                                ? series.startYear
                                                : 'Année de début inconnue',
                                            style: TextStyle(
                                              color: Colors.grey[300],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                  ),
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF15233D),
        selectedItemColor: Color(0xFF56CCF2),
        unselectedItemColor: Colors.grey[400],
        currentIndex: 2,
        onTap: (int index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => EcranAccueil()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ComicsPopulairesScreen()),
            );
          } else if (index == 2) {
            // Do nothing if current tab is selected
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => FilmsPopulairesScreen()),
            );
          } else if (index == 4) {
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
              color: Color(0xFF56CCF2), // Couleur sélectionnée pour l'icône "Séries"
            ),
            label: 'Séries',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/SVG/navbar_movies.png',
              width: 24,
              height: 24,
              color: Colors.grey[400],
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
