import 'common.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:comics/config.dart';


class Movies {
  final String id;
  final String imageUrl;
  final String name;
  final String releaseDate;
  final String runtime;
  final String apiDetailUrl;

  Movies({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.releaseDate,
    required this.runtime,
    required this.apiDetailUrl,
  });

  factory Movies.fromJson(Map<String, dynamic> json) {
    String defaultImageUrl = 'https://www.placecage.com/200/300';
    String id = json['id']?.toString() ?? '0000';
    String name = json['name']?.toString() ?? 'Unknown';
    String imageUrl = json['image'] != null ? json['image']['original_url'] ?? defaultImageUrl : defaultImageUrl;
    String releaseDate = json['release_date']?.toString() ?? 'Unknown';
    String runtime = json['runtime']?.toString() ?? 'Unknown';
    String apiDetailUrl = json['api_detail_url']?.toString() ?? 'Unknown';

    return Movies(
      id: id,
      imageUrl: imageUrl,
      name: name,
      releaseDate: releaseDate,
      runtime: runtime,
      apiDetailUrl: apiDetailUrl,
    );
  }

  Future<List<Movies>> fetchMovies({int limit = 10, int offset = 0}) async {
    final url = Uri.parse('https://comicvine.gamespot.com/api/movies?api_key=${Config.comicVineApiKey}&format=json&limit=$limit&offset=$offset&field_list=id,image,name,release_date,runtime,api_detail_url');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = List<Map<String, dynamic>>.from(data['results']);
      return results.map((json) => Movies.fromJson(json)).toList();
    } else {
      return handleError(response.statusCode);
    }
  }

  Future<List<Movies>> searchMovies(String query) async {
    final url = Uri.parse('https://comicvine.gamespot.com/api/search?api_key=${Config.comicVineApiKey}&format=json&resources=movie&query=$query&field_list=id,image,name,release_date,runtime,api_detail_url');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = List<Map<String, dynamic>>.from(data['results']);
      return results.map((json) => Movies.fromJson(json)).toList();
    } else {
      return handleError(response.statusCode);
    }
  }
}