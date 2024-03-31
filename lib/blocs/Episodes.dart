import 'package:http/http.dart' as http;
import 'dart:convert';
import 'common.dart';
import 'package:comics/config.dart';

class Episode {
  final String id;
  final String name;
  final String imageUrl;
  final String airDate;
  final String apiDetailUrl;
  final String episodeNumber;

  Episode({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.airDate,
    required this.apiDetailUrl,
    required this.episodeNumber,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    String defaultImageUrl = 'https://www.placecage.com/200/300';
    String id = json['id']?.toString() ?? '0000';
    String name = json['name']?.toString() ?? 'Unknown';
    String imageUrl = json['image'] != null ? json['image']['original_url'] ?? defaultImageUrl : defaultImageUrl;
    String airDate = json['air_date']?.toString() ?? 'Unknown';
    String apiDetailUrl = json['api_detail_url']?.toString() ?? 'Unknown';
    String episodeNumber = json['episode_number']?.toString() ?? 'Unknown';

    return Episode(
      id: id,
      imageUrl: imageUrl,
      name: name,
      airDate: airDate,
      apiDetailUrl: apiDetailUrl,
      episodeNumber: episodeNumber,
    );
  }
}



