import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'dart:io' show File;            // only used on mobile
import 'package:http/http.dart' as http;
import 'package:epubx/epubx.dart';

import 'package:path_provider/path_provider.dart';   // ONLY used on mobile, safe because guarded


class EpubService {
  // load from URL
  static Future<List<String>> loadChaptersFromUrl(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception("Failed to load EPUB from URL: $url");
    }

    return _extractChapters(response.bodyBytes);
  }


  // DOwnload EPUB (mobile)
  static Future<String> downloadAndSaveEpub(
      String remoteUrl, String bookId) async {
    
    if (kIsWeb) {
      throw Exception("downloadAndSaveEpub() is not supported on Web");
    }

    final response = await http.get(Uri.parse(remoteUrl));

    if (response.statusCode != 200) {
      throw Exception("Failed to download EPUB: $remoteUrl");
    }

    final dir = await getApplicationDocumentsDirectory();
    final path = "${dir.path}/$bookId.epub";

    final file = File(path);
    await file.writeAsBytes(response.bodyBytes);

    return path;
  }


  // Load EPUB from file
  static Future<List<String>> loadChaptersFromFile(String filePath) async {
    if (kIsWeb) {
      throw Exception("loadChaptersFromFile() is not supported on Web");
    }

    final bytes = await File(filePath).readAsBytes();
    return _extractChapters(bytes);
  }


  // get chapters
  static Future<List<String>> _extractChapters(Uint8List bytes) async {
    final book = await EpubReader.readBook(bytes);

    List<String> chapters = [];

    // Normal chapters
    if (book.Chapters != null && book.Chapters!.isNotEmpty) {
      for (var c in book.Chapters!) {
        chapters.add(_extractPlainTextFromChapter(c));
      }
      return chapters;
    }


    // use EPUB spine if format is wrong
    final spine = book.Schema?.Package?.Spine?.Items;
    final htmlFiles = book.Content?.Html;

    if (spine == null || htmlFiles == null) return [];

    for (var spineItem in spine) {
      final idRef = spineItem.IdRef;
      if (idRef == null) continue;

      final htmlEntry = htmlFiles[idRef];
      if (htmlEntry == null) continue;

      final html = htmlEntry.Content ?? "";
      chapters.add(_cleanHtml(html));
    }

    return chapters;
  }

  
  static String _cleanHtml(String html) {
    return html
        .replaceAll(RegExp(r"<[^>]*>", multiLine: true), "")
        .replaceAll("&nbsp;", " ")
        .replaceAll("&amp;", "&")
        .replaceAll("&quot;", "\"")
        .replaceAll("&apos;", "'")
        .replaceAll("&lt;", "<")
        .replaceAll("&gt;", ">")
        .trim();
  }

  static String _extractPlainTextFromChapter(EpubChapter chapter) {
    final buffer = StringBuffer();

    void extract(EpubChapter ch) {
      if (ch.HtmlContent != null) {
        buffer.writeln(_cleanHtml(ch.HtmlContent!));
      }
      for (var sub in ch.SubChapters ?? []) {
        extract(sub);
      }
    }

    extract(chapter);
    return buffer.toString();
  }
}
