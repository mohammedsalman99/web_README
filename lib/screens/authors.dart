import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'EditAuthor.dart';
import 'createauthor.dart';


class AuthorsPage extends StatefulWidget {
  @override
  _AuthorsPageState createState() => _AuthorsPageState();
}

class _AuthorsPageState extends State<AuthorsPage> {
  List<Map> authors = [];
  bool isLoading = true;
  final String _adminToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3MzkzMDZjZDU0OTI2NDI5ODg4MTY0ZCIsImlzQWRtaW4iOnRydWUsImlhdCI6MTczMzM4MzMyMCwiZXhwIjoxNzQxMTU5MzIwfQ.Lzl05Sx4-xm0DCUVPPPAQUtr6A2WB6gk4CXoQd1L8ro'; // Replace with your actual token

  @override
  void initState() {
    super.initState();
    fetchAuthors();
  }

  Future<void> fetchAuthors() async {
    try {
      final response = await http.get(
        Uri.parse('https://readme-backend-zdiq.onrender.com/api/v1/authors'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          authors = List<Map>.from(data['authors']);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load authors');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching authors: $e');
    }
  }



  void toggleVisibility(String authorId, bool isCurrentlyVisible) {
    setState(() {
      final index = authors.indexWhere((author) => author['_id'] == authorId);
      if (index != -1) {
        authors[index]['isVisible'] = !isCurrentlyVisible;
      }
    });
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, String authorId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1A1E28), // Dark background
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 50,
              color: Colors.orangeAccent,
            ),
            SizedBox(height: 20),
            Text(
              'Are you sure?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'You will not be able to recover this.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[300],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Yes, delete it!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final url = 'https://readme-backend-zdiq.onrender.com/api/v1/authors/$authorId';
        final response = await http.delete(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $_adminToken', // Admin token
          },
        );

        if (response.statusCode == 200) {
          setState(() {
            authors.removeWhere((author) => author['_id'] == authorId);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Author deleted successfully')),
          );
        } else {
          throw Exception('Failed to delete author: ${response.body}');
        }
      } catch (e) {
        print('Error deleting author: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting author: $e')),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFB2EBF2), Color(0xFFE0F7FA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 10,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Color(0xFF5AA5B1)),
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              fetchAuthors(); // Refresh authors list
            },
            tooltip: 'Refresh Authors',
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 500),
        child: isLoading
            ? Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB2EBF2)),
          ),
        )
            : authors.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people,
                size: 80,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'No authors available',
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
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery
                  .of(context)
                  .size
                  .width > 800
                  ? 4
                  : MediaQuery
                  .of(context)
                  .size
                  .width > 600
                  ? 3
                  : 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 0.9,
            ),
            itemCount: authors.length,
            itemBuilder: (context, index) {
              final author = authors[index];
              return AuthorCard(
                author: author,
                onDelete: (context, authorId) {
                  _showDeleteConfirmationDialog(context, authorId);
                },
                onEdit: (context, updatedAuthor) async {
                  final updated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditAuthorPage(author: author),
                    ),
                  );
                  if (updated != null) {
                    setState(() {
                      authors[index] = updated;
                    });
                  }
                },
                onToggleVisibility: toggleVisibility,
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final newAuthor = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateAuthorPage()),
          );
          if (newAuthor != null) {
            setState(() {
              authors.add(newAuthor);
            });
          }
        },
        icon: Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Author',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF5AA5B1),
        elevation: 10,
        tooltip: 'Add Author',
      ),
    );
  }
}

  class AuthorCard extends StatelessWidget {
  final Map author;
  final Function(BuildContext, String) onDelete;
  final Function(BuildContext, Map) onEdit;
  final Function(String, bool) onToggleVisibility;

  const AuthorCard({
    required this.author,
    required this.onDelete,
    required this.onEdit,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onEdit(context, author), // Navigate to edit page
      child: Card(
        elevation: 15,
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
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
                        author['profilePicture'] ?? '',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.image_not_supported,
                          size: 100,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.6),
                              Colors.transparent,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: author['isVisible'] ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          author['isVisible'] ? 'Visible' : 'Hidden',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 10,
                      right: 10,
                      child: Text(
                        author['fullName'],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.7),
                              offset: Offset(0, 1),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => onEdit(context, author),
                          icon: Icon(Icons.edit, size: 18, color: Colors.white),
                          label: Text('Edit', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => onDelete(context, author['_id']),
                          icon: Icon(Icons.delete, size: 18, color: Colors.white),
                          label: Text('Delete', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Toggle Visibility:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                        Switch(
                          value: author['isVisible'] ?? true,
                          onChanged: (value) {
                            onToggleVisibility(author['_id'], author['isVisible']);
                          },
                          activeColor: Colors.green,
                          inactiveThumbColor: Colors.red,
                          inactiveTrackColor: Colors.redAccent.withOpacity(0.5),
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
