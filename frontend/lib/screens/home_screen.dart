import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/remote_book.dart';
import 'reader_screen.dart';

// node server.js
// flutter run -d chrome

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<RemoteBook>> futureBooks;

  @override
  void initState() {
    super.initState();
    futureBooks = ApiService.fetchRemoteBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Library")),
      body: FutureBuilder<List<RemoteBook>>(
        future: futureBooks,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final books = snapshot.data!;

          if (books.isEmpty) {
            return const Center(child: Text("No books online found."));
          }

          return Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,      // ⬅ number of columns
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.62, // ⬅ cover aspect ratio
              ),
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReaderScreen(book: book),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 📕 COVER
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            book.coverUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) {
                              return Container(
                                color: Colors.grey.shade300,
                                child: const Icon(
                                  Icons.book,
                                  size: 40,
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      // 📖 TITLE
                      Text(
                        book.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

}
