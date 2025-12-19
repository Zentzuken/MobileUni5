class RemoteBook {
  final String id;
  final String title;
  final String coverUrl;
  final String epubUrl;
  String? filePath;       // local saved EPUB path
  int lastReadChapter;    // sync progress with backend

  RemoteBook({
    required this.id,
    required this.title,
    required this.coverUrl,
    required this.epubUrl,
    this.filePath,
    this.lastReadChapter = 0,
  });

  factory RemoteBook.fromJson(Map<String, dynamic> json) {
    return RemoteBook(
      id: json['id'].toString(),
      title: json['title'] ?? 'Untitled',
      coverUrl: json['coverUrl'] ?? '',
      epubUrl: json['epubUrl'] ?? '',
      filePath: json['filePath'],
      lastReadChapter: json['lastReadChapter'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'coverUrl': coverUrl,
      'epubUrl': epubUrl,
      'filePath': filePath,
      'lastReadChapter': lastReadChapter,
    };
  }
}


