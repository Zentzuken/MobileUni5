
import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../services/storage_service.dart';
//import '../services/epub_service.dart';

class ReaderScreen extends StatefulWidget {
  final Book book;
  const ReaderScreen({super.key, required this.book});

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
    //_loadBook();
  }

  /*
  Future<void> _loadBook() async {
    chapters = await EpubService.loadChapters(widget.book.filePath);
    currentChapter = widget.book.lastChapterIndex;
    setState(() => loading = false);
  }
  */

  void _nextChapter() {
    if (currentChapter < chapters.length - 1) {
      setState(() => currentChapter++);
      _saveProgress();
    }
  }

  void _prevChapter() {
    if (currentChapter > 0) {
      setState(() => currentChapter--);
      _saveProgress();
    }
  }

  Future<void> _saveProgress() async {
    widget.book.lastChapterIndex = currentChapter;
    await StorageService.updateBook(widget.book);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(chapters[currentChapter]),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: _prevChapter,
              child: const Text("Prev Chapter"),
            ),
            ElevatedButton(
              onPressed: _nextChapter,
              child: const Text("Next Chapter"),
            ),
          ],
        ),
      ),
    );
  }
}
