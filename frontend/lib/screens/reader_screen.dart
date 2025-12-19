import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // kIsWeb
import '../models/remote_book.dart';
import '../services/storage_service.dart';
import '../services/epub_service.dart';
import '../services/api_service.dart';

class ReaderScreen extends StatefulWidget {
  final RemoteBook book;
  const ReaderScreen({Key? key, required this.book}) : super(key: key);

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  List<String> chapters = [];
  int currentChapter = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadEpub();
  }

  // ---------- LOAD EPUB ----------
  Future<void> _loadEpub() async {
    setState(() => loading = true);

    try {
      debugPrint("==== EPUB LOAD START ====");
      debugPrint("Book ID: ${widget.book.id}");
      debugPrint("EPUB URL: ${widget.book.epubUrl}");
      debugPrint("Running on web: $kIsWeb");

      if (kIsWeb) {
        // WEB -> load directly from backend
        chapters = await EpubService.loadChaptersFromUrl(
          widget.book.epubUrl,
        );
      } else {
        // MOBILE
        String? localPath =
            await StorageService.getLocalPathForRemote(widget.book.id);

        if (localPath == null) {
          localPath = await EpubService.downloadAndSaveEpub(
            widget.book.epubUrl,
            widget.book.id,
          );

          await StorageService.saveRemoteLocalMapping(
            widget.book.id,
            localPath,
          );
        }

        chapters = await EpubService.loadChaptersFromFile(localPath);
      }

      debugPrint("Chapters loaded: ${chapters.length}");

      if (chapters.isEmpty) {
        debugPrint("WARNING: EPUB loaded but no chapters found");
      }

      currentChapter = await StorageService.getLastRead(widget.book.id);
      debugPrint("Last read chapter: $currentChapter");

      debugPrint("==== EPUB LOAD END ====");

    } catch (e, stack) {
      debugPrint("ERROR loading EPUB: $e");
      debugPrint("STACK TRACE:\n$stack");
    }

    setState(() => loading = false);
  }

  // ---------- SAVE PROGRESS ----------
  Future<void> _saveProgress() async {
    await StorageService.saveLastRead(widget.book.id, currentChapter);

    try {
      await ApiService.postProgress(
        bookIdOrFilePath: widget.book.id,
        chapterIndex: currentChapter,
      );
    } catch (e) {
      debugPrint("postProgress failed: $e");
    }
  }

  void _next() async {
    if (currentChapter < chapters.length - 1) {
      setState(() => currentChapter++);
      await _saveProgress();
    }
  }

  void _prev() async {
    if (currentChapter > 0) {
      setState(() => currentChapter--);
      await _saveProgress();
    }
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final chapterText = chapters.isNotEmpty
        ? chapters[currentChapter]
            .replaceAll(RegExp(r"<[^>]*>", multiLine: true), "")
        : "No content";

    return Scaffold(
      appBar: AppBar(title: Text(widget.book.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(
          chapterText,
          style: const TextStyle(fontSize: 16, height: 1.4),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _prev,
            ),
            Text("Chapter ${currentChapter + 1}/${chapters.length}"),
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: _next,
            ),
          ],
        ),
      ),
    );
  }
}
