import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'createbook.dart';
import 'editbook.dart';

class BooksPage extends StatefulWidget {
  @override
  _BooksPageState createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  List<Map> books = [];
  bool isLoading = true;
  final TextEditingController searchController = TextEditingController();
  List<Map> filteredBooks = [];

  final String _adminToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3MzkzMDZjZDU0OTI2NDI5ODg4MTY0ZCIsImlzQWRtaW4iOnRydWUsImlhdCI6MTczMzM4MzMyMCwiZXhwIjoxNzQxMTU5MzIwfQ.Lzl05Sx4-xm0DCUVPPPAQUtr6A2WB6gk4CXoQd1L8ro';

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    final url = 'https://readme-backend-zdiq.onrender.com/api/v1/books/all';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_adminToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          books = List<Map>.from(data['books']);
          filteredBooks = books; // Initialize filteredBooks
          isLoading = false;
        });
      } else {
        print('Failed to load books: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching books: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterBooks(String query) {
    setState(() {
      filteredBooks = books
          .where((book) {
        final title = book['title']?.toLowerCase() ?? '';
        final authors = (book['authors'] as List<dynamic>?)
            ?.map((author) => author['fullName']?.toLowerCase() ?? '')
            .toList();
        return title.contains(query.toLowerCase()) ||
            (authors?.any((author) => author.contains(query.toLowerCase())) ?? false);
      })
          .toList();
    });
  }



  Future<void> removeBook(String bookId) async {
    print('Attempting to delete book with ID: $bookId'); 
    final url = 'https://readme-backend-zdiq.onrender.com/api/v1/books/$bookId';

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_adminToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response from server: ${data['message']}'); 
        setState(() {
          books.removeWhere((book) => book['_id'] == bookId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Book deleted successfully!')),
        );
      } else {
        print('Failed to delete book. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete the book.')),
        );
      }
    } catch (e) {
      print('Error deleting book: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting the book.')),
      );
    }
  }


  Future<void> toggleVisibility(String bookId, bool currentVisibility) async {
    final url = 'https://readme-backend-zdiq.onrender.com/api/v1/books/$bookId/visibility';

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_adminToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'isVisible': !currentVisibility}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data['message']); 
        setState(() {
          final bookIndex = books.indexWhere((b) => b['_id'] == bookId);
          if (bookIndex != -1) {
            books[bookIndex]['isVisible'] = data['isVisible'];
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
      } else {
        print('Failed to toggle visibility: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update visibility.')),
        );
      }
    } catch (e) {
      print('Error toggling visibility: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while updating visibility.')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 500),
        child: isLoading
            ? const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB2EBF2)),
          ),
        )
            : books.isEmpty
            ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.book, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No books available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        )
            : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Search Books',
                    labelStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFFB2EBF2), width: 2),
                    ),
                  ),
                  onChanged: filterBooks, // Filter books on input
                ),
              ),
              // Grid View
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width > 800
                        ? 4
                        : MediaQuery.of(context).size.width > 600
                        ? 3
                        : 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: filteredBooks.length, // Use filteredBooks
                  itemBuilder: (context, index) {
                    final book = filteredBooks[index];
                    return BookCard(
                      book: book,
                      onEdit: (context, book) async {
                        final updatedBook = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditBookPage(bookId: book['_id']),
                          ),
                        );

                        if (updatedBook != null) {
                          setState(() {
                            final index = books.indexWhere(
                                    (b) => b['_id'] == book['_id']);
                            if (index != -1) {
                              books[index] = updatedBook;
                              filterBooks(searchController.text); // Re-filter
                            }
                          });
                        }
                      },
                      onDelete: (bookId) async {
                        await removeBook(bookId);
                        filterBooks(searchController.text); // Re-filter
                      },
                      onToggleVisibility: (bookId, currentVisibility) async {
                        await toggleVisibility(bookId, currentVisibility);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final newBook = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateBookPage()),
          );
          if (newBook != null) {
            setState(() {
              books.add(newBook);
              filterBooks(searchController.text); // Re-filter
            });
          }
        },
        icon: Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Book',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF5AA5B1),
        elevation: 10,
        tooltip: 'Add Book',
      ),
    );
  }

}


class BookCard extends StatelessWidget {
  final Map book;
  final Function(BuildContext, Map) onEdit;
  final Function(String) onDelete;
  final Function(String, bool) onToggleVisibility;

  const BookCard({
    required this.book,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onEdit(context, book), 
      child: Card(
        elevation: 15,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFB2EBF2), Color(0xFFE0F7FA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.teal.withOpacity(0.3),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      child: Image.network(
                        book['image'] ?? '',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.image_not_supported,
                          size: 100,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: book['isVisible'] ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          book['isVisible'] ? 'Visible' : 'Hidden',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book['title'] ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Category: ${book['category']?['title'] ?? 'Unknown'}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Author(s): ${book['authors']?.map((a) => a['fullName']).join(', ') ?? 'Unknown'}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => onEdit(context, book),
                          icon: const Icon(Icons.edit, size: 18,color: Colors.white),
                          label: const Text(
                            'Edit',
                            style: TextStyle(color: Colors.white), // Set text color to white
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            print('Delete button pressed for book ID: ${book['_id']}'); 

                            final bool? confirmDelete = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Row(
                                    children: [
                                      Icon(Icons.warning_amber_rounded, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text("Are you sure?"),
                                    ],
                                  ),
                                  content: Text(
                                    "You will not be able to recover this.",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(false); 
                                      },
                                      child: Text("Cancel", style: TextStyle(color: Colors.grey)),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(true); 
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: Text("Yes, delete it!", style: TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirmDelete == true) {
                              await onDelete(book['_id']); 
                            }
                          },
                          icon: const Icon(Icons.delete, size: 18,color: Colors.white),
                          label: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.white), // Set text color to white
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),



                        Column(
                          children: [
                            Text(
                              'Visibility',
                              style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                            ),
                            Switch(
                              value: book['isVisible'] ?? true,
                              onChanged: (value) async {
                                print('Toggling visibility for book ID: ${book['_id']} to $value'); 
                                await onToggleVisibility(book['_id'], book['isVisible'] ?? true);
                              },
                              activeColor: Colors.green,
                              inactiveThumbColor: Colors.red,
                              inactiveTrackColor: Colors.red[100],
                            ),

                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
