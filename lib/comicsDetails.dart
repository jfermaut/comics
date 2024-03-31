import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:http/http.dart' as http;
import 'package:comics/blocs/Comic.dart';
import 'package:comics/blocs/Characters.dart';
import 'package:comics/blocs/Person.dart';
import 'config.dart';

class ComicsDetailsScreen extends StatefulWidget {
  final String apiDetailUrl;

  ComicsDetailsScreen({required this.apiDetailUrl});

  @override
  _ComicsDetailsScreenState createState() => _ComicsDetailsScreenState();
}

class _ComicsDetailsScreenState extends State<ComicsDetailsScreen> {
  String _selectedOption = 'Histoire';
  late Future<Comic> _futureComic;
  late Future<List<Character>> _futureCharacters;

  @override
  void initState() {
    super.initState();
    _futureComic = fetchComic(apiDetailUrl: widget.apiDetailUrl);
  }

  Future<Comic> fetchComic({required String apiDetailUrl}) async {
    final url = Uri.parse('$apiDetailUrl?api_key=${Config.comicVineApiKey}&format=json&field_list=id,name,publisher,count_of_episodes,start_year,api_detail_url,image,description,characters');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final comic = Comic.fromJson(data['results']);
      _futureCharacters = fetchCharacters(seriesId: comic.id); // Passer le seriesId ici
      return comic;
    } else {
      throw Exception('Failed to load serie');
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
      body: FutureBuilder<Comic>(
        future: _futureComic,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final comics = snapshot.data!;
            final String publisherName = comics.name;

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
                          comics.imageUrl,
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
                                      comics.imageUrl,
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
                                          comics.issueNumber.isNotEmpty
                                              ? Image.asset(
                                            'assets/SVG/ic_books_bicolor.png',
                                            width: 16,
                                            height: 16,
                                            color: Colors.grey[300],
                                          )
                                              : Container(),
                                          SizedBox(width: 8),
                                          Text(
                                            comics.issueNumber,
                                            style: TextStyle(color: Colors.grey[300]),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          comics.coverDate.isNotEmpty
                                              ? Image.asset(
                                            'assets/SVG/ic_calendar_bicolor.png',
                                            width: 16,
                                            height: 16,
                                            color: Colors.grey[300],
                                          )
                                              : Container(),
                                          SizedBox(width: 8),
                                          Text(
                                            comics.coverDate,
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
                  title: Text(comics.name),
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
                              _buildOption('Auteurs'),
                              _buildOption('Personnages'),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: _buildSelectedOptionContent(comics),
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

  Widget _buildSelectedOptionContent(Comic comics) {
    switch (_selectedOption) {
      case 'Histoire':
        return HtmlWidget(
          comics.description,
          textStyle: TextStyle(color: Colors.white),
        );
      case 'Auteurs':
        if (_futureComic == null) {
          return Center(child: CircularProgressIndicator());
        } else {
          return FutureBuilder<Comic>(
            future: _futureComic!,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                final comic = snapshot.data!;
                final List<Person> creators = comic.creators;

                return Container(
                  height: 500,
                  child: ListView.builder(
                    itemCount: creators.length,
                    itemBuilder: (context, index) {
                      final author = creators[index];
                      return ListTile(
                        title: Text(author.name),
                      );
                    },
                  ),
                );
              }
            },
          );
        }
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
