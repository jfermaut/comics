import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'main.dart';
import 'films_populaires.dart';
import 'series_populaires.dart';
import 'comics_populaires.dart';
import 'comicsDetails.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String searchQuery = '';
  List<dynamic> comicsResults = [];
  List<dynamic> moviesResults = [];
  List<dynamic> seriesResults = [];
  bool isLoading = false;

  Future<void> performSearch(String query) async {
    setState(() {
      isLoading = true;
    });

    try {
      final comicsResponse = await http.get(Uri.parse('https://comicvine.gamespot.com/api/issues?api_key=${Config.comicVineApiKey}&format=json&query=$query'));
      if (comicsResponse.statusCode == 200) {
        setState(() {
          comicsResults = json.decode(comicsResponse.body)['results'];
        });
      } else {
        setState(() {
          comicsResults = [];
        });
        print('Erreur lors de la recherche de comics: ${comicsResponse.statusCode}');
      }

      // Appel d'API pour les films
      final moviesResponse = await http.get(Uri.parse('https://comicvine.gamespot.com/api/movies?api_key=${Config.comicVineApiKey}&format=json&query=$query'));
      if (moviesResponse.statusCode == 200) {
        setState(() {
          moviesResults = json.decode(moviesResponse.body)['results'];
        });
      } else {
        setState(() {
          moviesResults = [];
        });
        print('Erreur lors de la recherche de films: ${moviesResponse.statusCode}');
      }

      // Appel d'API pour les séries
      final seriesResponse = await http.get(Uri.parse('https://comicvine.gamespot.com/api/series?api_key=${Config.comicVineApiKey}&format=json&query=$query'));
      if (seriesResponse.statusCode == 200) {
        setState(() {
          seriesResults = json.decode(seriesResponse.body)['results'];
        });
      } else {
        setState(() {
          seriesResults = [];
        });
        print('Erreur lors de la recherche de séries: ${seriesResponse.statusCode}');
      }

    } catch (error) {
      print('Erreur lors de la recherche: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildComicsSection(List<dynamic> comics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: comics.map<Widget>((comic) {
              final title = comic['name'] ?? 'Titre inconnu';
              final imageUrl = comic['image']['small_url'] ?? '';

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ComicsDetailsScreen(
                        apiDetailUrl: comic['api_detail_url'],
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 180,
                  height: 200,
                  color: Color(0xFF2D4455),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                           Image.network(
                        imageUrl,
                        width: 120,
                        height: 160,
                        fit: BoxFit.cover,
                      )
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF2D4455),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(10, MediaQuery.of(context).padding.top + 10, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Recherche',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 7),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color(0xFF15232E),
                      ),
                      child: TextFormField(
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                          performSearch(value);
                        },
                        style: TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        decoration: InputDecoration(
                          hintText: 'Comic, film, série...',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                          suffixIcon: Icon(Icons.search, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF1E3243),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saisissez une recherche pour trouver un comics, film, série ou personnage',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 10),
                        if (isLoading)
                          Center(child: CircularProgressIndicator())
                        else
                          Column(
                            children: [
                              _buildComicsSection(comicsResults),
                              _buildSearchResultsSection("Films", moviesResults),
                              _buildSearchResultsSection("Séries", seriesResults),
                            ],
                          ),
                      ],
                    ),
                    Positioned(
                      top: -40,
                      right: 10,
                      child: Image.asset(
                        'assets/SVG/astronaut.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Color(0xFF15233D),
          selectedItemColor: Color(0xFF56CCF2),
          unselectedItemColor: Colors.grey[400],
          currentIndex: 4,
          onTap: (int index) {
            switch (index) {
              case 0:
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EcranAccueil()));
                break;
              case 1:
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ComicsPopulairesScreen()));
                break;
              case 2:
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SeriesPopulairesScreen()));
                break;
              case 3:
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FilmsPopulairesScreen()));
                break;
              case 4:
              // Ne rien faire car nous sommes déjà sur la page de recherche
                break;
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
                color: Color(0xFF56CCF2),
              ),
              label: 'Recherche',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultsSection(String title, List<dynamic> results) {
    return results.isEmpty
        ? Container(
      padding: EdgeInsets.all(16),
    )
        : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: results.map<Widget>((result) {
              final title = result['title'] ?? 'Titre inconnu';

              return Container(
                margin: EdgeInsets.only(right: 10),
                width: 120,
                height: 180,
                color: Colors.grey[800],
                child: Center(child: Text(title, style: TextStyle(color: Colors.white))),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
