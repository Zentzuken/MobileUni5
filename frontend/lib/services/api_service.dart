import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/remote_book.dart';
import 'package:flutter/foundation.dart';



class ApiService {
  /// IMPORTANT:
  /// For Android emulator: 10.0.2.2
  /// For Web: localhost
  /// For real device: http://YOUR_PC_IP:3000
  static const String baseUrl =
      kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000'; // change if needed


  /// GET /api/books
  static Future<List<RemoteBook>> fetchRemoteBooks() async {
    final uri = Uri.parse('$baseUrl/api/books');

    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Failed to load books: ${res.statusCode}');
    }

    final List<dynamic> decoded = jsonDecode(res.body);
    return decoded.map((e) => RemoteBook.fromJson(e)).toList();
  }

  /// Download EPUB and save locally
  static Future<String> downloadEpubToLocal(
      String url, String filename) async {
    final uri = Uri.parse(url);
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Failed to download epub: ${res.statusCode}');
    }

    final bytes = res.bodyBytes;

    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/$filename';
    final file = File(filePath);

    await file.writeAsBytes(bytes, flush: true);

    return filePath;
  }

  /// POST /api/progress
  static Future<void> postProgress({
    required String bookIdOrFilePath,
    required int chapterIndex,
  }) async {
    final uri = Uri.parse('$baseUrl/api/progress');

    final body = jsonEncode({
      'id': bookIdOrFilePath,
      'chapter': chapterIndex,
      'timestamp': DateTime.now().toIso8601String(),
    });

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Failed to post progress: ${res.statusCode}');
    }
  }
}
