import 'Person.dart';
import 'dart:convert';
import 'package:comics/config.dart';
import 'package:http/http.dart' as http;
import 'common.dart';

class Character {
  late final String id;
  late final String imageUrl;
  late final String name;
  late final String apiDetailUrl;
  late final String description;
  late final String realName;
  late final List<String> aliases;
  late final String publisher;
  late final List<Person> creators;
  late final String gender;
  late final String birth;

  Character({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.apiDetailUrl,
    required this.description,
    required this.realName,
    required this.aliases,
    required this.publisher,
    required this.creators,
    required this.gender,
    required this.birth,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    String id = json['id']?.toString() ?? '0000';
    String name = json['name']?.toString() ?? 'Unknown';
    String imageUrl = json['image'] != null ? json['image']['original_url'] ?? 'path/to/image' : 'path/to/image';
    String apiDetailUrl = json['api_detail_url']?.toString() ?? 'Unknown';
    String description = json['description']?.toString() ?? 'No description available';
    String realName = json['real_name']?.toString() ?? 'Unknown';
    String aliasesString = json['aliases']?.toString() ?? '';
    List<String> aliases = aliasesString.split('\n').where((alias) => alias.isNotEmpty).toList();
    String publisher = json['publisher'] != null ? json['publisher']['name']?.toString() ?? 'Unknown' : 'Unknown';
    List<dynamic> creatorsList = json['creators'] ?? [];
    List<Person> creators = creatorsList.map((creator) => Person.fromJson(creator)).toList();
    String gender = json['gender']?.toString() ?? 'Unknown';
    String birth = json['birth']?.toString() ?? 'Unknown';

    return Character(
      id: id,
      imageUrl: imageUrl,
      name: name,
      apiDetailUrl: apiDetailUrl,
      description: description,
      realName: realName,
      aliases: aliases,
      publisher: publisher,
      creators: creators,
      gender: gender,
      birth: birth,
    );
  }

  factory Character.fromSearchJson(Map<String, dynamic> json) {
    String id = json['id']?.toString() ?? '0000';
    String name = json['name']?.toString() ?? 'Unknown';
    String imageUrl = json['image'] != null ? json['image']['original_url'] ?? 'path/to/image' : 'path/to/image';
    String apiDetailUrl = json['api_detail_url']?.toString() ?? 'Unknown';

    return Character(
      id: id,
      imageUrl: imageUrl,
      name: name,
      apiDetailUrl: apiDetailUrl,
      description: '',
      realName: '',
      aliases: [],
      publisher: '',
      creators: [],
      gender: '',
      birth: '',
    );
  }

  void updateFromJson(Map<String, dynamic> json) {
    imageUrl = json['image'] != null ? json['image']['original_url'] ?? 'path/to/image' : 'path/to/image';
  }

  void updateDetailsFromJson(Map<String, dynamic> json) {
    String description = json['description']?.toString() ?? 'No description available';
    String realName = json['real_name']?.toString() ?? 'Unknown';
    String aliasesString = json['aliases']?.toString() ?? '';
    List<String> aliases = aliasesString.split('\n').where((alias) => alias.isNotEmpty).toList();
    String publisher = json['publisher'] != null ? json['publisher']['name']?.toString() ?? 'Unknown' : 'Unknown';
    List<dynamic> creatorsList = json['creators'] ?? [];
    List<Person> creators = creatorsList.map((creator) => Person.fromJson(creator)).toList();
    String gender = json['gender']?.toString() ?? 'Unknown';
    String birth = json['birth']?.toString() ?? 'Unknown';

    this.description = description;
    this.realName = realName;
    this.aliases = aliases;
    this.publisher = publisher;
    this.creators = creators;
    this.gender = gender;
    this.birth = birth;
  }

  Future<List<Character>> fetchCharacters({int limit = 10, int offset = 0}) async {
    final url = Uri.parse('https://comicvine.gamespot.com/api/characters?api_key=${Config.comicVineApiKey}&format=json&limit=$limit&offset=$offset&field_list=id,name,api_detail_url');
    return await _performRequest(url);
  }

  Future<List<Character>> fetchCharactersImage(List<Character> characters) async {
    int sublistEndIndex = characters.length > 10 ? 10 : characters.length;
    List<Future<Character>> characterFutures = characters.sublist(0, sublistEndIndex).map((character) async {
      final url = Uri.parse('${character.apiDetailUrl}?api_key=${Config.comicVineApiKey}&format=json&field_list=image');
      return await _performRequestForSingleCharacterImage(url, character);
    }).toList();

    return Future.wait(characterFutures);
  }

  Future<Character> fetchCharacterDetails(Character character) async {
    final url = Uri.parse('${character.apiDetailUrl}?api_key=${Config.comicVineApiKey}&format=json&field_list=description,real_name,aliases,publisher,creators,gender,birth');
    return await _performRequestForSingleCharacterDetails(url, character);
  }

  Future<List<Character>> searchCharacters(String query) async {
    final url = Uri.parse('https://comicvine.gamespot.com/api/search?api_key=${Config.comicVineApiKey}&format=json&resources=character&query=$query&field_list=id,name,image,api_detail_url');
    return await _performRequestSearch(url);
  }

  Future<List<Character>> _performRequest(Uri url) async {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = List<Map<String, dynamic>>.from(data['results']);
      return results.map((json) => Character.fromJson(json)).toList();
    } else {
      return handleError(response.statusCode);
    }
  }

  Future<List<Character>> _performRequestSearch(Uri url) async {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = List<Map<String, dynamic>>.from(data['results']);
      return results.map((json) => Character.fromSearchJson(json)).toList();
    } else {
      return handleError(response.statusCode);
    }
  }

  Future<Character> _performRequestForSingleCharacterImage(Uri url, Character characterToUpdate) async {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      characterToUpdate.updateFromJson(data['results']);
      return characterToUpdate;
    } else {
      return Future.error(handleError(response.statusCode));
    }
  }

  Future<Character> _performRequestForSingleCharacterDetails(Uri url, Character characterToUpdate) async {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      characterToUpdate.updateDetailsFromJson(data['results']);
      return characterToUpdate;
    } else {
      return Future.error(handleError(response.statusCode));
    }
  }
}
