import 'Characters.dart';
import 'Episodes.dart';

class Serie {
  final String id;
  final String name;
  final String publisher;
  final int countOfEpisodes;
  final String startYear;
  final String apiDetailUrl;
  final String imageUrl;
  final String description;
  final List<Character> characters;
  late List<Episode> episodes;

  Serie({
    required this.id,
    required this.name,
    required this.publisher,
    required this.countOfEpisodes,
    required this.startYear,
    required this.apiDetailUrl,
    required this.imageUrl,
    required this.description,
    required this.characters,
  });

  factory Serie.fromJson(Map<String, dynamic> json) {
    String defaultImageUrl = 'https://www.placecage.com/200/300';
    String id = json['id']?.toString() ?? '0000';
    String name = json['name']?.toString() ?? 'Unknown';
    String imageUrl = json['image'] != null ? json['image']['original_url'] ?? defaultImageUrl : defaultImageUrl;
    String publisher = json['publisher'] != null ? json['publisher']['name']?.toString() ?? 'Unknown' : 'Unknown';
    int countOfEpisodes = json['count_of_episodes']?.toInt() ?? 0;
    String startYear = json['start_year'] != null ? json['start_year']?.toString() ?? 'Unknown' : 'Unknown';
    String apiDetailUrl = json['api_detail_url']?.toString() ?? '';
    String description = json['description']?.toString() ?? 'Unknown';
    List<Character> characters = (json['characters'] as List<dynamic>?)?.map((e) => Character.fromJson(e)).toList() ?? [];


    return Serie(
      id: id,
      imageUrl: imageUrl,
      name: name,
      publisher: publisher,
      countOfEpisodes: countOfEpisodes,
      startYear: startYear,
      apiDetailUrl: apiDetailUrl,
      description: description,
      characters: characters,
    );
  }

  void setEpisodes(List<Episode> episodes){
    this.episodes = episodes;
  }
}
