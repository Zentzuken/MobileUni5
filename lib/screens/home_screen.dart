
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/book_model.dart';
import '../services/storage_service.dart';
import 'reader_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Book> books = [];

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    final loadedBooks = await StorageService.loadBooks();
    setState(() => books = loadedBooks);
  }

  Future<void> _addBook() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['epub'],
    );
    if (result != null) {
      final filePath = result.files.single.path!;
      final newBook = Book(title: result.files.single.name, filePath: filePath);
      await StorageService.saveBook(newBook);
      setState(() => books.add(newBook));
    }
  }

  void _openBook(Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ReaderScreen(book: book)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Library")),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.7,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return GestureDetector(
            onTap: () => _openBook(book),
            child: Container(
              color: Colors.grey[300],
              alignment: Alignment.center,
              child: Text(
                book.title,
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addBook,
        child: const Icon(Icons.add),
      ),
    );
  }
}
