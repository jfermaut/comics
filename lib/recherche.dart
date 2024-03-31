import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'main.dart';
import 'films_populaires.dart';
import 'series_populaires.dart';
import 'comics_populaires.dart';
import 'comicsDetails.dart';
import 'SerieDetails.dart';
import 'MoviesDetails.dart';

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

      final seriesResponse = await http.get(Uri.parse('https://comicvine.gamespot.com/api/series_list?api_key=${Config.comicVineApiKey}&format=json&query=$query'));
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

  Widget buildSeriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: seriesResults.map<Widget>((series) {
              final title = series['name'] ?? 'Titre inconnu';
              final imageUrl = series['image']['small_url'] ?? '';

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SerieDetailsScreen(
                        apiDetailUrl: series['api_detail_url'],
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 200,
                  height: 240,
                  margin: EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Color(0xFF2D4455),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            imageUrl,
                            width: 200,
                            height: 160,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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

  Widget buildComicsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: comicsResults.map<Widget>((comic) {
              final title = comic['volume']['name'] ?? 'Titre inconnu';
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
                  width: 200,
                  height: 240,
                  margin: EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Color(0xFF2D4455),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            imageUrl,
                            width: 200,
                            height: 160,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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

  Widget buildMoviesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: moviesResults.map<Widget>((movies) {
              final title = movies['name'] ?? 'Titre inconnu';
              final imageUrl = movies['image']['small_url'] ?? '';

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MoviesDetailsScreen(moviesDetails: movies),
                    ),
                  );
                },
                child: Container(
                  width: 200,
                  height: 240,
                  margin: EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Color(0xFF2D4455),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            imageUrl,
                            width: 200,
                            height: 160,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
                        if (searchQuery.toLowerCase() == 'comics')
                          buildComicsSection()
                        else if (searchQuery.toLowerCase() == 'series')
                          buildSeriesSection()
                        else if (searchQuery.toLowerCase() == 'films')
                            buildMoviesSection()
                          else
                            Column(
                              children: [
                                Text(
                                  'Saisissez une recherche pour trouver un comics, film, série ou personnage',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                      ],
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

  Widget buildSearchResultsSection(String title, List<dynamic> results) {
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
