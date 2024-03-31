import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:http/http.dart' as http;
import 'package:comics/blocs/Episodes.dart';
import 'package:comics/blocs/Serie.dart';
import 'package:comics/blocs/Characters.dart';
import 'config.dart';

class SerieDetailsScreen extends StatefulWidget {
  final String apiDetailUrl;

  SerieDetailsScreen({required this.apiDetailUrl});

  @override
  _SerieDetailsScreenState createState() => _SerieDetailsScreenState();
}

class _SerieDetailsScreenState extends State<SerieDetailsScreen> {
  String _selectedOption = 'Histoire';
  late Future<Serie> _futureSerie;
  late Future<List<Episode>> _futureEpisodes;
  late Future<List<Character>> _futureCharacters;

  @override
  void initState() {
    super.initState();
    _futureSerie = fetchSerie(apiDetailUrl: widget.apiDetailUrl);
  }

  Future<Serie> fetchSerie({required String apiDetailUrl}) async {
    final url = Uri.parse('$apiDetailUrl?api_key=${Config.comicVineApiKey}&format=json&field_list=id,name,publisher,count_of_episodes,start_year,api_detail_url,image,description,characters');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final serie = Serie.fromJson(data['results']);
      _futureEpisodes = fetchEpisodes(seriesId: serie.id);
      _futureCharacters = fetchCharacters(seriesId: serie.id); // Passer le seriesId ici
      return serie;
    } else {
      throw Exception('Failed to load serie');
    }
  }


  Future<List<Episode>> fetchEpisodes({required String seriesId}) async {
    final url = Uri.parse('https://comicvine.gamespot.com/api/episodes/?api_key=${Config.comicVineApiKey}&format=json&filter=series:$seriesId&field_list=id,name,image,air_date,api_detail_url,episode_number');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final episodes = data['results'] as List<dynamic>;
      return episodes.map((e) => Episode.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load episodes');
    }
  }

  Future<List<Character>> fetchCharacters({required String seriesId}) async {
    final url = Uri.parse('https://comicvine.gamespot.com/api/characters?api_key=${Config.comicVineApiKey}&format=json&limit=10&offset=0&filter=series:$seriesId&field_list=id,name,image');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final characters = data['results'] as List<dynamic>;
      return characters.map((e) => Character.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load characters');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Serie>(
        future: _futureSerie,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final serie = snapshot.data!;
            final String publisherName = serie.publisher;
            final String episodesCount = serie.countOfEpisodes.toString();

            return CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  expandedHeight: 300.0,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          serie.imageUrl,
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
                                      serie.imageUrl,
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
                                      Row(
                                        children: [
                                          Flexible(
                                            child: publisherName.isNotEmpty
                                                ? Image.asset(
                                              'assets/SVG/ic_publisher_bicolor.png',
                                              width: 16,
                                              height: 16,
                                              color: Colors.grey[300],
                                            )
                                                : Container(),
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              publisherName,
                                              style: TextStyle(color: Colors.grey[300]),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          serie.countOfEpisodes > 0
                                              ? Image.asset(
                                            'assets/SVG/ic_tv_bicolor.png',
                                            width: 16,
                                            height: 16,
                                            color: Colors.grey[300],
                                          )
                                              : Container(),
                                          SizedBox(width: 8),
                                          Text(
                                            episodesCount,
                                            style: TextStyle(color: Colors.grey[300]),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          serie.startYear.isNotEmpty
                                              ? Image.asset(
                                            'assets/SVG/ic_calendar_bicolor.png',
                                            width: 16,
                                            height: 16,
                                            color: Colors.grey[300],
                                          )
                                              : Container(),
                                          SizedBox(width: 8),
                                          Text(
                                            serie.startYear,
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
                  title: Text(serie.name),
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
                              _buildOption('Histoire'),
                              _buildOption('Personnages'),
                              _buildOption('Épisodes'),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: _buildSelectedOptionContent(serie),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildOption(String text) {
    return TextButton(
      onPressed: () {
        setState(() {
          _selectedOption = text;
        });
      },
      child: Container(
        padding: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: _selectedOption == text ? Colors.orange : Colors.transparent,
              width: 2,
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

  Widget _buildEpisodesInfo(List<Episode> episodes) {
    if (episodes.isEmpty) {
      return Center(
        child: Text(
          "Aucun épisode n'est disponible dans notre base de données.",
          style: TextStyle(color: Colors.white),
        ),
      );
    } else {
      return Container(
        height: 500,
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 10),
          itemCount: episodes.length,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.all(8.0),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: const Color(0xFF284C6A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      episodes[index].imageUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Episode #${episodes[index].episodeNumber}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          episodes[index].name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            Image.asset(
                              'assets/SVG/ic_calendar_bicolor.png',
                              width: 16,
                              height: 16,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              episodes[index].airDate,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }
  }

  Widget _buildSelectedOptionContent(Serie serie) {
    switch (_selectedOption) {
      case 'Histoire':
        return HtmlWidget(
          serie.description,
          textStyle: TextStyle(color: Colors.white),
        );
      case 'Personnages':
        return FutureBuilder<List<Character>>(
          future: _futureCharacters,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.data == null) {
              return Center(child: Text('No data available'));
            } else {
              final characters = snapshot.data!;
              return _buildCharactersList(characters);
            }
          },
        );
      case 'Épisodes':
        return FutureBuilder<List<Episode>>(
          future: _futureEpisodes,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.data == null) {
              return Center(child: Text('No data available'));
            } else {
              final episodes = snapshot.data!;
              return _buildEpisodesInfo(episodes);
            }
          },
        );
      default:
        return Container();
    }
  }

  Widget _buildCharactersList(List<Character> characters) {
    return Container(
      height: 500,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 10),
        itemCount: characters.length,
        itemBuilder: (context, index) {
          final character = characters[index];
          return ListTile(
            title: Text(character.name),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(character.imageUrl),
            ),
          );
        },
      ),
    );
  }
}
