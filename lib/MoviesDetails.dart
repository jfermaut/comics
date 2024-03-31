import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:comics/blocs/Movie.dart';
import 'package:comics/blocs/common.dart';

class MoviesDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> moviesDetails;
  List<dynamic> characters = [];
  bool isLoading = true;

  MoviesDetailsScreen({required this.moviesDetails});

  @override
  _MoviesDetailsScreenState createState() => _MoviesDetailsScreenState();
}

class _MoviesDetailsScreenState extends State<MoviesDetailsScreen> {
  String _selectedOption = 'Synopsis';

  @override
  void initState() {
    super.initState();
    fetchMovieCharacters();
  }

  Future<void> fetchMovieCharacters() async {
    final String apiKey = Config.comicVineApiKey;
    final String movieId = widget.moviesDetails['id'].toString();
    final String charactersEndpoint = 'characters';
    final String apiUrl =
        'https://comicvine.gamespot.com/api/$charactersEndpoint/?api_key=$apiKey&format=json&filter=movies:$movieId';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          widget.characters = json.decode(response.body)['results'].take(10).toList();
          widget.isLoading = false;
        });
      } else {
        print('Erreur lors de la récupération des personnages: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la récupération des personnages: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 300.0,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.moviesDetails['image']['medium_url'],
                    fit: BoxFit.cover,
                  ),
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                    child: Container(
                      height: 400,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                  Positioned(
                    bottom: 35.0,
                    left: 0.0,
                    right: 0.0,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                      color: Colors.transparent,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 140,
                            height: 170,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                widget.moviesDetails['image']['medium_url'],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 16),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    widget.moviesDetails['runtime'] != null
                                        ? Image.asset(
                                      'assets/SVG/ic_movie_bicolor.png',
                                      width: 16,
                                      height: 16,
                                      color: Colors.grey[300],
                                    )
                                        : Container(),
                                    SizedBox(width: 8),
                                    Text(
                                      widget.moviesDetails['runtime'] != null
                                          ? '${widget.moviesDetails['runtime']} minutes'
                                          : 'Durée inconnue',
                                      style: TextStyle(color: Colors.grey[300]),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    widget.moviesDetails['release_date'] != null
                                        ? Image.asset('assets/SVG/ic_calendar_bicolor.png',
                                        width: 16, height: 16, color: Colors.grey[300])
                                        : Container(),
                                    SizedBox(width: 8),
                                    Text(
                                      widget.moviesDetails['release_date'] != null
                                          ? widget.moviesDetails['release_date'] ?? ''
                                          : 'Date de sortie inconnue',
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
                ],
              ),
            ),
            title: Text(widget.moviesDetails['name'] ?? ''),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 500,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                    color: Colors.transparent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildOption('Synopsis'),
                        _buildOption('Personnages'),
                        _buildOption('Infos'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildSelectedOptionContent(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(String text) {
    return TextButton(
      onPressed: () {
        setState(() {
          _selectedOption = text; // Mettre à jour l'option sélectionnée
        });
      },
      child: Container(
        padding: EdgeInsets.only(bottom: 10), // Espace pour le soulignement
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: _selectedOption == text ? Colors.orange : Colors.transparent,
              width: 2, // Épaisseur du soulignement
            ),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: _selectedOption == text ? Colors.orange : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedOptionContent() {
    switch (_selectedOption) {
      case 'Synopsis':
        return HtmlWidget(
          widget.moviesDetails['description'] ?? '',
          textStyle: TextStyle(color: Colors.white),
        );
      case 'Personnages':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                widget.characters.length,
                    (index) => ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(widget.characters[index]['image']['medium_url']),
                  ),
                  title: Text(
                    widget.characters[index]['name'] ?? '',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        );
      case 'Infos':
        return _buildMovieInfo();
      default:
        return Container();
    }
  }



  Widget _buildMovieInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        Row(
          children: [
            Text(
              'Classification:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(width: 16),
            Text(
              widget.moviesDetails['rating'] ?? 'N/A',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Text(
              'Réalisateurs:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(width: 16),
            Flexible(
              child: Wrap(
                spacing: 8,
                children: (widget.moviesDetails['producers'] as List<dynamic>).map<Widget>((producer) {
                  return Text(
                    producer['name'] ?? 'N/A',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Text(
              'Scénaristes:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(width: 16),
            Flexible(
              child: Wrap(
                spacing: 8,
                children: (widget.moviesDetails['writers'] as List<dynamic>).map<Widget>((writer) {
                  return Text(
                    writer['name'] ?? 'N/A',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Text(
              'Producteurs:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(width: 16),
            Flexible(
              child: Wrap(
                spacing: 8,
                children: (widget.moviesDetails['producers'] as List<dynamic>).map<Widget>((producer) {
                  return Text(
                    producer['name'] ?? 'N/A',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Text(
              'Studios:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(width: 16),
            Flexible(
              child: Wrap(
                spacing: 8,
                children: (widget.moviesDetails['studios'] as List<dynamic>).map<Widget>((studio) {
                  return Text(
                    studio['name'] ?? 'N/A',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Text(
              'Budget:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(width: 16),
            Text(
              '${widget.moviesDetails['budget'] ?? 'N/A'} \$',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Text(
              'Recettes au box-office:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(width: 16),
            Text(
              '${widget.moviesDetails['box_office_revenue'] ?? 'N/A'} \$',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Text(
              'Recettes brut totales:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(width: 16),
            Text(
              '${widget.moviesDetails['total_revenue'] ?? 'N/A'} \$',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }
}
