class BrochureModel {
  final int id;
  final String title;
  final String course;
  final String url;

  BrochureModel({
    required this.id,
    required this.title,
    required this.course,
    required this.url,
  });

  // Server ki keys backend ke hisaab se badal lena
  factory BrochureModel.fromJson(Map<String, dynamic> json) {
    return BrochureModel(
      id: json['id'] ?? 0,
      title: (json['title'] ?? '').toString(),
      course: (json['course'] ?? '').toString(),
      url: (json['url'] ?? '').toString(),
    );
  }
}