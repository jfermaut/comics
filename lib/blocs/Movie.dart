import 'Characters.dart';
import 'Person.dart';
import 'sutios.dart';


class Movie {
  final String id;
  final String name;
  final String imageUrl;
  final List<Person> producers;
  final String releaseDate;
  final String runtime;
  final String totalRevenue;
  final  List<Person> writers;
  final String boxOfficeRevenue;
  final String budget;
  final  List<Character> characters;
  final List<Studio> studios;
  final String description;
  final String rating;
  final String apiDetailUrl;

  Movie({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.producers,
    required this.releaseDate,
    required this.runtime,
    required this.totalRevenue,
    required this.writers,
    required this.boxOfficeRevenue,
    required this.budget,
    required this.characters,
    required this.studios,
    required this.description,
    required this.rating,
    required this.apiDetailUrl,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    String defaultImageUrl = 'https://www.placecage.com/200/300';
    String id = json['id']?.toString() ?? '0000';
    String name = json['name']?.toString() ?? 'Unknown';
    String imageUrl = json['image'] != null ? json['image']['original_url'] ?? defaultImageUrl : defaultImageUrl;
    String releaseDate = json['release_date']?.toString() ?? 'Unknown';
    String runtime = json['runtime']?.toString() ?? 'Unknown';
    String totalRevenue = json['total_revenue']?.toString() ?? 'Unknown';
    List<Person> producers = (json['producers'] as List<dynamic>?)?.map((e) => Person.fromJson(e)).toList() ?? [];
    List<Person> writers = (json['writers'] as List<dynamic>?)?.map((e) => Person.fromJson(e)).toList() ?? [];
    String boxOfficeRevenue = json['box_office_revenue']?.toString() ?? 'Unknown';
    String budget = json['budget']?.toString() ?? 'Unknown';
    List<Character> characters = (json['characters'] as List<dynamic>?)?.map((e) => Character.fromJson(e)).toList() ?? [];
    List<Studio> studios = (json['studios'] as List<dynamic>?)?.map((e) => Studio.fromJson(e)).toList() ?? [];
    String description = json['description']?.toString() ?? 'Unknown';
    String rating = json['rating']?.toString() ?? 'Unknown';
    String apiDetailUrl = json['api_detail_url']?.toString() ?? 'Unknown';

    return Movie(
      id: id,
      imageUrl: imageUrl,
      name: name,
      producers: producers,
      releaseDate: releaseDate,
      runtime: runtime,
      totalRevenue: totalRevenue,
      writers: writers,
      boxOfficeRevenue: boxOfficeRevenue,
      budget: budget,
      characters: characters,
      studios: studios,
      description: description,
      rating: rating,
      apiDetailUrl: apiDetailUrl,
    );
  }





}