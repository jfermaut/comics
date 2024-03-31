import 'dart:convert';
import 'package:comics/config.dart';
import 'package:http/http.dart' as http;
import 'common.dart';


class Person{
  late String id;
  late String name;
  late String imageUrl;
  late String apiDetailUrl;
  late String country;

  Person({required this.id, required this.name, required this.apiDetailUrl});

  factory Person.fromJson(Map<String, dynamic> json) {
    String id = json['id']?.toString() ?? '0000';
    String name = json['name']?.toString() ?? 'Unknown';
    String apiDetailUrl = json['api_detail_url']?.toString() ?? '';

    return Person(
      id: id,
      name: name,
      apiDetailUrl: apiDetailUrl,
    );
  }

  void updateFromJson(Map<String, dynamic> json) {
    imageUrl = json['image'] != null ? json['image']['original_url'] ?? 'path/to/image' : 'path/to/image';
    country = json['country']?.toString() ?? 'Unknown';
  }

  factory Person.fromSearchJson(Map<String, dynamic> json) {
    String id = json['id']?.toString() ?? '0000';
    String name = json['name']?.toString() ?? 'Unknown';
    String imageUrl = json['image'] != null ? json['image']['original_url'] ?? 'path/to/image' : 'path/to/image';
    String apiDetailUrl = json['api_detail_url']?.toString() ?? '';

    Person person = Person(
      id: id,
      name: name,
      apiDetailUrl: apiDetailUrl,
    );
    person.imageUrl = imageUrl;

    return person;
  }


  Future<List<Person>> fetchPersons({int limit = 10, int offset = 0}) async {
    final url = Uri.parse('https://comicvine.gamespot.com/api/people?api_key=${Config.comicVineApiKey}&format=json&limit=$limit&offset=$offset&field_list=id,name,image,api_detail_url');
    return await _performRequest(url);
  }

  Future<List<Person>> fetchPersonsDetails(List<Person> persons) async {
    int sublistEndIndex = persons.length > 10 ? 10 : persons.length; // Détermine la fin de la sous-liste basée sur la condition
    List<Future<Person>> personFutures = persons.sublist(0, sublistEndIndex).map((person) async {
      final url = Uri.parse('${person.apiDetailUrl}?api_key=${Config.comicVineApiKey}&format=json&field_list=image');
      return await _performRequestForSinglePerson(url, person);
    }).toList();

    return Future.wait(personFutures);
  }

  Future<List<Person>> searchPersons(String query) async {
    final url = Uri.parse('https://comicvine.gamespot.com/api/search?api_key=${Config.comicVineApiKey}&format=json&resources=person&query=$query&field_list=id,name,image,api_detail_url');
    return await _performRequestSearch(url);
  }

  Future<List<Person>> _performRequest(Uri url) async {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = List<Map<String, dynamic>>.from(data['results']);
      return results.map((json) => Person.fromJson(json)).toList();
    } else {
      return handleError(response.statusCode);
    }
  }

  Future<List<Person>> _performRequestSearch(Uri url) async {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = List<Map<String, dynamic>>.from(data['results']);
      return results.map((json) => Person.fromSearchJson(json)).toList();
    } else {
      return handleError(response.statusCode);
    }
  }

  Future<Person> _performRequestForSinglePerson(Uri url, Person personToUpdate) async {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      personToUpdate.updateFromJson(data['results']);
      return personToUpdate;
    } else {
      return Future.error(handleError(response.statusCode));
    }
  }
}