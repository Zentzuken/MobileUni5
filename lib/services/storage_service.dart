import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book_model.dart';

class StorageService {
  static const String key = "books";

  static Future<List<Book>> loadBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(key) ?? [];
    return data.map((e) => Book.fromJson(jsonDecode(e))).toList();
  }

  static Future<void> saveBook(Book book) async {
    final prefs = await SharedPreferences.getInstance();
    final books = await loadBooks();
    books.add(book);
    final encoded = books.map((b) => jsonEncode(b.toJson())).toList();
    await prefs.setStringList(key, encoded);
  }

  static Future<void> updateBook(Book book) async {
    final prefs = await SharedPreferences.getInstance();
    final books = await loadBooks();
    final index = books.indexWhere((b) => b.filePath == book.filePath);
    if (index != -1) books[index] = book;
    final encoded = books.map((b) => jsonEncode(b.toJson())).toList();
    await prefs.setStringList(key, encoded);
  }

  static Future<void> saveRemoteLocalMapping(String remoteId, String localPath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('remote_map_$remoteId', localPath);
  }

  static Future<String?> getLocalPathForRemote(String remoteId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('remote_map_$remoteId');
  }

  static Future<String?> getRemoteIdForLocalPath(String localPath) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (final k in keys) {
      if (k.startsWith('remote_map_')) {
        final val = prefs.getString(k);
        if (val == localPath) {
          return k.replaceFirst('remote_map_', '');
        }
      }
    }
    return null;
  }
}
