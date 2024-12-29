import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardPage extends StatefulWidget {
  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<DashboardPage> {
  int categoryCount = 0;
  int authorCount = 0;
  int bookCount = 0;
  int transactionCount = 0;
  int reviewCount = 0;
  int reportCount = 0;
  List<dynamic> popularBooks = [];
  List<dynamic> latestBooks = [];
  int userCount = 0;


  @override
  void initState() {
    super.initState();
    fetchCategoryCount();
    fetchAuthorCount();
    fetchBookCount();
    fetchTransactionCount();
    fetchReviewCount();
    fetchTotalReports();
    fetchPopularAndLatestBooks();
    fetchUserCount(); // Add this line

  }

  Future<void> fetchPopularAndLatestBooks() async {
    final url = 'https://readme-backend-zdiq.onrender.com/api/v1/books';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final books = data['books'] ?? [];

        popularBooks = List.from(books)
          ..sort((a, b) => (b['numberOfViews'] ?? 0).compareTo(a['numberOfViews'] ?? 0));

        latestBooks = List.from(books)
          ..sort((a, b) => DateTime.parse(b['createdAt']).compareTo(DateTime.parse(a['createdAt'])));

        popularBooks = popularBooks.take(10).toList();
        latestBooks = latestBooks.take(10).toList();

        setState(() {}); 
      } else {
        print('Failed to fetch books. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching books: $error');
    }
  }

  Future<void> fetchTransactionCount() async {
    final url =
        'https://readme-backend-zdiq.onrender.com/api/v1/transactions/admin/all?type=SUBSCRIPTION&status=COMPLETED&startDate=2024-01-01&endDate=2025-12-31&limit=10&page=1';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization':
          'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3MzkzMDZjZDU0OTI2NDI5ODg4MTY0ZCIsImlzQWRtaW4iOnRydWUsImlhdCI6MTczMzM4MzMyMCwiZXhwIjoxNzQxMTU5MzIwfQ.Lzl05Sx4-xm0DCUVPPPAQUtr6A2WB6gk4CXoQd1L8ro',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          transactionCount = data['pagination']['total'] ?? 0; 
        });
      } else {
        print('Failed to fetch transactions. Status Code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      print('Error fetching transactions: $error');
    }
  }

  Future<void> fetchReviewCount() async {
    final bookId = '6742251767dbfff613fefcb3';
    final url = 'https://readme-backend-zdiq.onrender.com/api/v1/books/$bookId/reviews';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization':
          'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3MzkzMDZjZDU0OTI2NDI5ODg4MTY0ZCIsImlzQWRtaW4iOnRydWUsImlhdCI6MTczMzM4MzMyMCwiZXhwIjoxNzQxMTU5MzIwfQ.Lzl05Sx4-xm0DCUVPPPAQUtr6A2WB6gk4CXoQd1L8ro',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Reviews API Response: ${response.body}'); 
        setState(() {
          reviewCount = data['reviews']?.length ?? 0;
        });
      } else {
        print('Failed to fetch reviews. Status Code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      print('Error fetching reviews: $error');
    }
  }

  Future<void> fetchTotalReports() async {
    final url = 'https://readme-backend-zdiq.onrender.com/api/v1/books/:bookId/reports'; 
    int totalReports = 0;

    try {
      print('Starting request to $url...');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization':
          'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3MzkzMDZjZDU0OTI2NDI5ODg4MTY0ZCIsImlzQWRtaW4iOnRydWUsImlhdCI6MTczMzM4MzMyMCwiZXhwIjoxNzQxMTU5MzIwfQ.Lzl05Sx4-xm0DCUVPPPAQUtr6A2WB6gk4CXoQd1L8ro',
        },
      );

      print('Response received. Status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        print('Response data: $data');

        if (data != null && data['reports'] != null) {
          final reports = data['reports'];
          totalReports = reports.length; 

          print('Reports fetched successfully.');
          print('Total reports: $totalReports');
        } else {
          print('No reports found in the response.');
        }
      } else {
        print('Failed to fetch reports. Status Code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      setState(() {
        reportCount = totalReports;
      });
      print('Report count updated: $reportCount');
    } catch (error) {
      print('Error fetching reports: $error');
    }
  }



  Future<void> fetchBookCount() async {
    final url = 'https://readme-backend-zdiq.onrender.com/api/v1/books';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          bookCount = data['books'].length;
        });
      } else {
        print('Failed to fetch book count');
      }
    } catch (error) {
      print('Error fetching book count: $error');
    }
  }

  Future<void> fetchAuthorCount() async {
    final url = 'https://readme-backend-zdiq.onrender.com/api/v1/authors';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          authorCount = data['authors'].length;
        });
      } else {
        print('Failed to fetch author count');
      }
    } catch (error) {
      print('Error fetching author count: $error');
    }
  }


  Future<void> fetchCategoryCount() async {
    final url = 'https://readme-backend-zdiq.onrender.com/api/v1/categories';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          categoryCount = data['categories'].length;
        });
      } else {
        print('Failed to fetch category count');
      }
    } catch (error) {
      print('Error fetching category count: $error');
    }
  }

  Future<void> fetchUserCount() async {
    final url = 'https://readme-backend-zdiq.onrender.com/api/v1/users/count';
    const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3MzkzMDZjZDU0OTI2NDI5ODg4MTY0ZCIsImlzQWRtaW4iOnRydWUsImlhdCI6MTczMzM4MzMyMCwiZXhwIjoxNzQxMTU5MzIwfQ.Lzl05Sx4-xm0DCUVPPPAQUtr6A2WB6gk4CXoQd1L8ro'; // Replace with your actual token

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token', // Add the Authorization header
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userCount = data['count'] ?? 0;
        });
      } else {
        print('Failed to fetch user count. Status Code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      print('Error fetching user count: $error');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5), 
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CategoryCountCard(categoryCount: categoryCount),
                  AuthorCountCard(authorCount: authorCount),
                  BookCountCard(bookCount: bookCount),
                  TransactionCountCard(transactionCount: transactionCount),
                  ReviewCountCard(reviewCount: reviewCount),
                  ReportCountCard(reportCount: reportCount),
                  UserCountCard(userCount: userCount), // Add this line
                ],
              ),

              SizedBox(height: 30),

              SectionTitle(title: 'Popular Books'),
              SizedBox(height: 10),
              BookList(books: popularBooks),
              SizedBox(height: 30),

              SectionTitle(title: 'Latest Books'),
              SizedBox(height: 10),
              BookList(books: latestBooks),
            ],
          ),
        ),
      ),
    );
  }


}
class CategoryCountCard extends StatelessWidget {
  final int categoryCount;

  const CategoryCountCard({
    Key? key,
    required this.categoryCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Color(0xFF5AA5B1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category,
            size: 50,
            color: Colors.white,
          ),
          SizedBox(height: 16),
          Text(
            'Categories',
            style: TextStyle(
              color:Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 8),
          Text(
            categoryCount.toString(),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
          ),
        ],
      ),
    );
  }
}

class AuthorCountCard extends StatelessWidget {
  final int authorCount;

  const AuthorCountCard({
    Key? key,
    required this.authorCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color:  Color(0xFF5AA5B1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person,
            size: 50,
            color: Colors.white,
          ),
          SizedBox(height: 16),
          Text(
            'Authors',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 8),
          Text(
            authorCount.toString(),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
          ),
        ],
      ),
    );
  }
}

class BookCountCard extends StatelessWidget {
  final int bookCount;

  const BookCountCard({
    Key? key,
    required this.bookCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Color(0xFF5AA5B1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book,
            size: 50,
            color: Colors.white,
          ),
          SizedBox(height: 16),
          Text(
            'Books',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 8),
          Text(
            bookCount.toString(),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionCountCard extends StatelessWidget {
  final int transactionCount;

  const TransactionCountCard({
    Key? key,
    required this.transactionCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Color(0xFF5AA5B1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.monetization_on,
            size: 50,
            color: Colors.white,
          ),
          SizedBox(height: 16),
          Text(
            'Transactions',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 8),
          Text(
            transactionCount.toString(),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
          ),
        ],
      ),
    );
  }
}


class ReviewCountCard extends StatelessWidget {
  final int reviewCount;

  const ReviewCountCard({
    Key? key,
    required this.reviewCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Color(0xFF5AA5B1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rate_review,
            size: 50,
            color: Colors.white,
          ),
          SizedBox(height: 16),
          Text(
            'Reviews',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 8),
          Text(
            reviewCount.toString(),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
          ),
        ],
      ),
    );
  }
}

class ReportCountCard extends StatelessWidget {
  final int reportCount;

  const ReportCountCard({
    Key? key,
    required this.reportCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Color(0xFF5AA5B1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.report,
            size: 50,
            color: Colors.white,
          ),
          SizedBox(height: 16),
          Text(
            'Reports',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 8),
          Text(
            reportCount.toString(),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}
class BookList extends StatelessWidget {
  final List<dynamic> books;

  const BookList({Key? key, required this.books}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return BookCard(book: book);
        },
      ),
    );
  }
}
class BookCard extends StatelessWidget {
  final dynamic book;

  const BookCard({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200, 
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 12), 
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: SingleChildScrollView( 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                book['image'] ?? '',
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    color: Colors.grey[200],
                    child: Icon(Icons.book, size: 50, color: Colors.grey),
                  );
                },
              ),
            ),
            SizedBox(height: 12),

            Text(
              book['title'] ?? 'Unknown Title',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),

            Text(
              book['category']?['title'] ?? 'Unknown Category',
              style: TextStyle(
                fontSize: 14,
                color: Colors.blueGrey,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 8),

            Text(
              book['description'] ?? 'No description available.',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.visibility, size: 16, color: Colors.redAccent),
                    SizedBox(width: 4),
                    Text(
                      '${book['numberOfViews']} Views',
                      style: TextStyle(fontSize: 14, color: Colors.redAccent),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.orange),
                    SizedBox(width: 4),
                    Text(
                      '${book['rating'] ?? 'N/A'}',
                      style: TextStyle(fontSize: 14, color: Colors.orange),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),

            if (book['authors'] != null && book['authors'].isNotEmpty)
              Text(
                'Author: ${book['authors'][0]['fullName'] ?? 'Unknown Author'}',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
          ],
        ),
      ),
    );
  }
}
class UserCountCard extends StatelessWidget {
  final int userCount;

  const UserCountCard({
    Key? key,
    required this.userCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Color(0xFF5AA5B1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people,
            size: 50,
            color: Colors.white,
          ),
          SizedBox(height: 16),
          Text(
            'Users',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 8),
          Text(
            userCount.toString(),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
          ),
        ],
      ),
    );
  }
}
