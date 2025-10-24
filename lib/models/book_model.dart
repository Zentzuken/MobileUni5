
class Book {
  final String title;
  final String filePath;
  int lastChapterIndex;

  Book({
    required this.title,
    required this.filePath,
    this.lastChapterIndex = 0,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'filePath': filePath,
        'lastChapterIndex': lastChapterIndex,
      };

  static Book fromJson(Map<String, dynamic> json) => Book(
        title: json['title'],
        filePath: json['filePath'],
        lastChapterIndex: json['lastChapterIndex'] ?? 0,
      );
}
