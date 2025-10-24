import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class RemoteBook {
  final String id;
  final String title;
  final String coverUrl;
  final String epubUrl;

  RemoteBook({
    required this.id,
    required this.title,
    required this.coverUrl,
    required this.epubUrl,
  });

  factory RemoteBook.fromJson(Map<String, dynamic> json) {
    return RemoteBook(
      id: json['id'].toString(),
      title: json['title'] ?? 'Untitled',
      coverUrl: json['coverUrl'] ?? '',
      epubUrl: json['epubUrl'] ?? '',
    );
  }
}

class ApiService {
  static const String baseUrl = 'http://localhost:3000';

  static Future<List<RemoteBook>> fetchRemoteBooks() async {
    final uri = Uri.parse('$baseUrl/books');
    final res = await http.get(uri);
    if (res.statusCode != 200) throw Exception('Failed to load books');
    final List<dynamic> decoded = jsonDecode(res.body);
    return decoded.map((e) => RemoteBook.fromJson(e)).toList();
  }

  static Future<String> downloadEpubToLocal(String url, String filename) async {
    final uri = Uri.parse(url);
    final res = await http.get(uri);
    if (res.statusCode != 200) throw Exception('Failed to download epub');
    final bytes = res.bodyBytes;
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/$filename';
    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);
    return filePath;
  }

  static Future<void> postProgress({
    required String bookIdOrFilePath,
    required int chapterIndex,
  }) async {
    final uri = Uri.parse('$baseUrl/progress');
    final body = jsonEncode({
      'book': bookIdOrFilePath,
      'chapter': chapterIndex,
      'timestamp': DateTime.now().toIso8601String(),
    });
    final res = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: body);
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Failed to post progress: ${res.statusCode}');
    }
  }
}
