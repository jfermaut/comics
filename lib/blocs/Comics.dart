import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:comics/config.dart';
import 'common.dart';

class Comics {
  final String id;
  final String imageUrl;
  final String name;
  final Map<String, dynamic> volume;
  final String issueNumber;
  final String coverDate;
  final String apiDetailUrl;

  Comics({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.volume,
    required this.issueNumber,
    required this.coverDate,
    required this.apiDetailUrl,
  });

  factory Comics.fromJson(Map<String, dynamic> json) {
    String defaultImageUrl = 'https://www.placecage.com/200/300';
    String id = json['id']?.toString() ?? '0000';
    String name = json['name']?.toString() ?? 'Unknown';
    String imageUrl = json['image'] != null ? json['image']['original_url'] ?? defaultImageUrl : defaultImageUrl;
    Map<String, dynamic> volume = json['volume'] ?? {};
    String issueNumber = json['issue_number']?.toString() ?? 'Unknown';
    String coverDate = json['cover_date']?.toString() ?? 'Unknown';
    String apiDetailUrl = json['api_detail_url']?.toString() ?? 'Unknown';

    return Comics(
      id: id,
      imageUrl: imageUrl,
      name: name,
      volume: volume,
      issueNumber: issueNumber,
      coverDate: coverDate,
      apiDetailUrl: apiDetailUrl,
    );
  }

  Future<List<Comics>> fetchComics({int limit = 10, int offset = 0}) async {
    final url = Uri.parse('https://comicvine.gamespot.com/api/issues?api_key=${Config.comicVineApiKey}&format=json&limit=$limit&offset=$offset&field_list=id,image,name,volume,issue_number,cover_date,api_detail_url');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = List<Map<String, dynamic>>.from(data['results']);
      return results.map((json) => Comics.fromJson(json)).toList();
    } else {
      return handleError(response.statusCode);
    }
  }
}
