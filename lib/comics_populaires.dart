import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'comicsDetails.dart';
import 'main.dart';
import 'series_populaires.dart';
import 'films_populaires.dart';
import 'recherche.dart';

class ComicsPopulairesScreen extends StatefulWidget {
  @override
  _ComicsPopulairesScreenState createState() => _ComicsPopulairesScreenState();
}

class _ComicsPopulairesScreenState extends State<ComicsPopulairesScreen> {
  List<dynamic> comics = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchComics();
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
        print('Erreur lors de la récupération des séries: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la récupération des séries: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF15232E),
        title: Text('Comics les plus populaires'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: comics.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
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
              child: Stack(
                children: [
                  if (comics[index]['image'] != null && comics[index]['image']['medium_url'] != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        padding: EdgeInsets.all(8.0),
                        color: Color(0xFF2D4455),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 150,
                              height: 150,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(
                                  comics[index]['image']['medium_url'],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0, bottom: 14.0),
                                    child: Text(
                                      comics[index]['volume']['name'] ?? 'Titre inconnu',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        comics[index]['name'] ?? 'Titre inconnu',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      if (comics[index]['deck'] != null)
                                        Text(
                                          comics[index]['deck'].toString(),
                                          style: TextStyle(color: Colors.grey[300]),
                                        ),
                                      SizedBox(width: 4),
                                      comics[index]['issue_number'] != null
                                          ? Image.asset(
                                        'assets/SVG/ic_books_bicolor.png',
                                        width: 16,
                                        height: 16,
                                        color: Colors.grey[300],
                                      )
                                          : Container(),
                                      SizedBox(width: 4),
                                      Text(
                                        comics[index]['issue_number'] != null
                                            ? 'N° ${comics[index]['issue_number']}'
                                            : 'Nombre d\'épisodes inconnu',
                                        style: TextStyle(color: Colors.grey[300]),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      comics[index]['cover_date'] != null
                                          ? Image.asset(
                                        'assets/SVG/ic_calendar_bicolor.png',
                                        width: 16,
                                        height: 16,
                                        color: Colors.grey[300],
                                      )
                                          : Container(),
                                      SizedBox(width: 4),
                                      Text(
                                        comics[index]['cover_date'] != null
                                            ? '${comics[index]['cover_date']}'
                                            : 'Date de sortie inconnue',
                                        style: TextStyle(color: Colors.grey[300]),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                ],
                              ),
                            ),
                          ],
                        ),
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
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF15233D),
        selectedItemColor: Color(0xFF56CCF2),
        unselectedItemColor: Colors.grey[400],
        currentIndex: 1,
        onTap: (int index) {
          if (index == 0) { // Accueil
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SeriesPopulairesScreen()),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => FilmsPopulairesScreen()),
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
              color: Colors.grey[400],
            ),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/SVG/navbar_comics.png',
              width: 24,
              height: 24,
              color: Color(0xFF56CCF2),
            ),
            label: 'Comics',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/SVG/navbar_series.png',
              width: 24,
              height: 24,
              color: Colors.grey[400],
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
