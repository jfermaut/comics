class Studio{
  final String id;
  final String name;

  Studio({
    required this.id,
    required this.name,
  });

  factory Studio.fromJson(Map<String, dynamic> json) {
    String id = json['id']?.toString() ?? '0000';
    String name = json['name']?.toString() ?? 'Unknown';

    return Studio(
      id: id,
      name: name,
    );
  }
}