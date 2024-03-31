import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:comics/config.dart';
import 'Characters.dart';
import 'Person.dart';
import 'common.dart';

class Comic{
  final String id;
  final String imageUrl;
  final String name;
  final Map<String, dynamic> volume;
  final String issueNumber;
  final String coverDate;
  final List<Character> characters;
  final List<Person> creators;
  final String description;
  final String apiDetailUrl;

  Comic({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.volume,
    required this.issueNumber,
    required this.coverDate,
    required this.characters,
    required this.creators,
    required this.description,
    required this.apiDetailUrl,
  });

  factory Comic.fromJson(Map<String, dynamic> json) {
    String defaultImageUrl = 'https://www.placecage.com/200/300';
    String id = json['id']?.toString() ?? '0000';
    String name = json['name']?.toString() ?? 'Unknown';
    String imageUrl = json['image'] != null ? json['image']['original_url'] ?? defaultImageUrl : defaultImageUrl;
    Map<String, dynamic> volume = json['volume'] ?? {};
    String issueNumber = json['issue_number']?.toString() ?? 'Unknown';
    String coverDate = json['cover_date']?.toString() ?? 'Unknown';
    List<Character> characters = (json['character_credits'] as List<dynamic>?)?.map((e) => Character.fromJson(e)).toList() ?? [];
    List<Person> creators = (json['person_credits'] as List<dynamic>?)?.map((e) => Person.fromJson(e)).toList() ?? [];
    String description = json['description']?.toString() ?? '';
    String apiDetailUrl = json['api_detail_url']?.toString() ?? '';

    return Comic(
      id: id,
      imageUrl: imageUrl,
      name: name,
      volume: volume,
      issueNumber: issueNumber,
      coverDate: coverDate,
      characters: characters,
      creators: creators,
      description: description,
      apiDetailUrl: apiDetailUrl,
    );
  }

  Future<List<Comic>> searchComics(String query) async {
    final url = Uri.parse('https://comicvine.gamespot.com/api/search?api_key=${Config.comicVineApiKey}&format=json&resources=issue&query=$query&field_list=id,image,name,volume,issue_number,cover_date,character_credits,person_credits,api_detail_url,description');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = List<Map<String, dynamic>>.from(data['results']);
      return results.map((json) => Comic.fromJson(json)).toList();
    } else {
      return handleError(response.statusCode);
    }
  }
}
