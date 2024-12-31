import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AllReviewsPage extends StatefulWidget {
  @override
  _AllReviewsPageState createState() => _AllReviewsPageState();
}

class _AllReviewsPageState extends State<AllReviewsPage> {
  static const String booksApiUrl =
      'https://readme-backend-zdiq.onrender.com/api/v1/books';
  static const String reviewsApiUrlTemplate =
      'https://readme-backend-zdiq.onrender.com/api/v1/books/:bookId/reviews';
  static const String adminToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3MzkzMDZjZDU0OTI2NDI5ODg4MTY0ZCIsImlzQWRtaW4iOnRydWUsImlhdCI6MTczMzM4MzMyMCwiZXhwIjoxNzQxMTU5MzIwfQ.Lzl05Sx4-xm0DCUVPPPAQUtr6A2WB6gk4CXoQd1L8ro';

  List<Map<String, dynamic>> _allReviews = [];
  bool _isLoading = false;
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredReviews = [];


  @override
  void initState() {
    super.initState();
    _fetchAllReviews();
  }

  Future<void> _fetchAllReviews() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('Fetching all books...');
      final booksResponse = await http.get(
        Uri.parse(booksApiUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (booksResponse.statusCode == 200) {
        final booksData = json.decode(booksResponse.body);
        final List<Map<String, dynamic>> books =
        List<Map<String, dynamic>>.from(booksData['books'] ?? []);
        print('Fetched ${books.length} books.');

        List<Future> reviewFutures = [];

        for (var book in books) {
          final bookId = book['_id'];
          final reviewsApiUrl =
          reviewsApiUrlTemplate.replaceAll(':bookId', bookId);
          print('Queuing reviews fetch for book ID: $bookId...');

          final reviewsFuture = http.get(
            Uri.parse(reviewsApiUrl),
            headers: {
              'Authorization': 'Bearer $adminToken',
              'Content-Type': 'application/json',
            },
          ).then((reviewsResponse) {
            if (reviewsResponse.statusCode == 200) {
              final reviewsData = json.decode(reviewsResponse.body);
              final List<Map<String, dynamic>> bookReviews =
              List<Map<String, dynamic>>.from(reviewsData['reviews'] ?? []);
              print('Fetched ${bookReviews.length} reviews for book ID: $bookId.');

              for (var review in bookReviews) {
                review['book'] = book;
              }

              setState(() {
                _allReviews.addAll(bookReviews);
                filteredReviews = _allReviews; 
              });
            } else {
              print('Failed to fetch reviews for book ID: $bookId');
            }
          }).catchError((e) {
            print('Error fetching reviews for book ID: $bookId - $e');
          });

          reviewFutures.add(reviewsFuture);
        }

        await Future.wait(reviewFutures);
      } else {
        print('Failed to fetch books: ${booksResponse.statusCode}');
      }
    } catch (e, stackTrace) {
      print('Error occurred: $e');
      print('Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading reviews: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }




  void _searchReviews(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredReviews = _allReviews; 
      } else {
        filteredReviews = _allReviews.where((review) {
          final bookTitle = review['book']?['title']?.toLowerCase() ?? '';
          final userName = review['user']?['fullName']?.toLowerCase() ?? '';
          final reviewText = review['review']?.toLowerCase() ?? '';
          final searchQuery = query.toLowerCase();

          return bookTitle.contains(searchQuery) ||
              userName.contains(searchQuery) ||
              reviewText.contains(searchQuery);
        }).toList();
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF5AA5B1),
        title: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search reviews...',
              hintStyle: TextStyle(color: Colors.grey),
              prefixIcon: Icon(Icons.search, color: Colors.teal),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFFB2EBF2), width: 2),
              ),
            ),
            onChanged: _searchReviews,
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),



      body: RefreshIndicator(
        onRefresh: _fetchAllReviews,
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
          itemCount: filteredReviews.length,
          itemBuilder: (context, index) {
            return _buildReviewCard(filteredReviews[index]);
          },
        ),
      ),


    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final book = review['book'];
    final bookTitle = book != null && book['title'] is String
        ? book['title']
        : 'Unknown Book';
    final bookImage = book != null && book['image'] is String
        ? book['image']
        : null;
    final user = review['user'];
    final userName = user != null && user['fullName'] is String
        ? user['fullName']
        : 'Unknown User';
    final userProfilePicture = user != null && user['profilePicture'] is String
        ? user['profilePicture']
        : null;

    final reviewText = review['review'] ?? 'No review provided.';
    final rating = review['rating'] ?? 0;

    final createdAt = review['createdAt'] ?? '';
    final updatedAt = review['updatedAt'] ?? '';
    final formattedCreatedAt = _formatAdvancedDate(createdAt);
    final formattedUpdatedAt = createdAt != updatedAt ? _formatAdvancedDate(updatedAt) : null;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB2EBF2), Color(0xFFE0F7FA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 6),
              blurRadius: 12,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: userProfilePicture != null
                        ? NetworkImage(userProfilePicture)
                        : null,
                    child: userProfilePicture == null
                        ? Icon(Icons.person, size: 30, color: Colors.grey)
                        : null,
                    backgroundColor: Colors.white,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00796B),
                          ),
                        ),
                        Text(
                          "Posted: $formattedCreatedAt",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        if (formattedUpdatedAt != null)
                          Text(
                            "Updated: $formattedUpdatedAt",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                  if (bookImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        bookImage,
                        height: 60,
                        width: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 16),

              Row(
                children: [
                  Icon(Icons.book, size: 20, color: Color(0xFF004D40)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      bookTitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF004D40),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),

              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  reviewText,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF004D40),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 12),

              Row(
                children: [
                  Text(
                    "Rating:",
                    style: TextStyle(fontSize: 14, color: Color(0xFF00796B)),
                  ),
                  SizedBox(width: 6),
                  Row(
                    children: List.generate(
                      5,
                          (index) => Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        size: 20,
                        color: Colors.orangeAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  String _formatAdvancedDate(String date) {
    try {
      final DateTime parsedDate = DateTime.parse(date);
      final Duration difference = DateTime.now().difference(parsedDate);

      if (difference.inMinutes < 60) {
        return "${difference.inMinutes} minutes ago";
      } else if (difference.inHours < 24) {
        return "${difference.inHours} hours ago";
      } else if (difference.inDays < 7) {
        return "${difference.inDays} days ago";
      } else {
        return "${parsedDate.day}-${parsedDate.month}-${parsedDate.year} at ${parsedDate.hour}:${parsedDate.minute.toString().padLeft(2, '0')}";
      }
    } catch (e) {
      return "Unknown Date";
    }
  }

}
