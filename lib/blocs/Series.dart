class Series {
  final String id;
  final String imageUrl;
  final String name;
  final String publisher;
  final int countOfEpisodes;
  final String startYear;
  final String apiDetailUrl;

  Series({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.publisher,
    required this.countOfEpisodes,
    required this.startYear,
    required this.apiDetailUrl,
  });

  factory Series.fromJson(Map<String, dynamic> json) {
    String defaultImageUrl = 'https://www.placecage.com/200/300';
    String id = json['id']?.toString() ?? '0000';
    String name = json['name']?.toString() ?? 'Unknown';
    String imageUrl = json['image'] != null ? json['image']['original_url'] ?? defaultImageUrl : defaultImageUrl;
    String publisher = json['publisher'] != null ? json['publisher']['name']?.toString() ?? 'Unknown' : 'Unknown';
    int countOfEpisodes = json['count_of_episodes']?.toInt() ?? 0;
    String startYear = json['start_year'] != null ? json['start_year']?.toString() ?? 'Unknown' : 'Unknown';
    String apiDetailUrl = json['api_detail_url']?.toString() ?? '';

    return Series(
      id: id,
      imageUrl: imageUrl,
      name: name,
      publisher: publisher,
      countOfEpisodes: countOfEpisodes,
      startYear: startYear,
      apiDetailUrl: apiDetailUrl,
    );
  }
}