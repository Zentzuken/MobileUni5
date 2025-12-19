import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/remote_book.dart';

class StorageService {
  static const String key = "saved_books";

  /// Load list of saved book metadata
  static Future<List<RemoteBook>> loadBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(key) ?? [];
    return list.map((e) => RemoteBook.fromJson(jsonDecode(e))).toList();
  }

  /// Save metadata only
  static Future<void> saveBook(RemoteBook book) async {
    final prefs = await SharedPreferences.getInstance();
    final books = await loadBooks();

    if (!books.any((b) => b.id == book.id)) {
      books.add(book);
    }

    final encoded = books.map((b) => jsonEncode(b.toJson())).toList();
    await prefs.setStringList(key, encoded);
  }

  /// Update book metadata
  static Future<void> updateBook(RemoteBook updated) async {
    final prefs = await SharedPreferences.getInstance();
    final books = await loadBooks();

    final index = books.indexWhere((b) => b.id == updated.id);
    if (index != -1) {
      books[index] = updated;
    }

    final encoded = books.map((b) => jsonEncode(b.toJson())).toList();
    await prefs.setStringList(key, encoded);
  }


  /// Save path mapping for WEB
  static Future<void> saveRemoteLocalMapping(String remoteId, String localPath) async {
    if (kIsWeb) return; // web cannot save local paths
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('remote_map_$remoteId', localPath);
  }

  /// Get local path for a remote EPUB (mobile only)
  static Future<String?> getLocalPathForRemote(String remoteId) async {
    if (kIsWeb) return null; // always null on web
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('remote_map_$remoteId');
  }

  /// Reverse lookup for mobile usin local path
  static Future<String?> getRemoteIdForLocalPath(String localPath) async {
    if (kIsWeb) return null; // disabled on web
    final prefs = await SharedPreferences.getInstance();

    for (final key in prefs.getKeys()) {
      if (key.startsWith('remote_map_')) {
        final val = prefs.getString(key);
        if (val == localPath) {
          return key.replaceFirst('remote_map_', '');
        }
      }
    }

    return null;
  }

  // last read
  static Future<void> saveLastRead(String bookId, int chapter) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_read_$bookId', chapter);
  }

  static Future<int> getLastRead(String bookId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('last_read_$bookId') ?? 0;
  }
}
