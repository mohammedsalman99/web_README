import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:syncfusion_flutter_charts/charts.dart';


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
    fetchUserCount();
    fetchTransactionTypeCounts();
    fetchTopReportedBooks();
    fetchTopViewedBooks();
    fetchGenderData();
  }
  Map<String, int> transactionTypeCounts = {
    'BOOK_PURCHASE': 0,
    'SUBSCRIPTION': 0,
  };

  Future<List<PieChartData>> fetchGenderData() async {
    const url = 'https://readme-backend-zdiq.onrender.com/api/v1/users/all';
    const String token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3MzkzMDZjZDU0OTI2NDI5ODg4MTY0ZCIsImlzQWRtaW4iOnRydWUsImlhdCI6MTczMzM4MzMyMCwiZXhwIjoxNzQxMTU5MzIwfQ.Lzl05Sx4-xm0DCUVPPPAQUtr6A2WB6gk4CXoQd1L8ro'; // Replace with your admin token

    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final users = data['users'] as List;

        int maleCount = 0;
        int femaleCount = 0;

        for (var user in users) {
          if (user['gender'] == 'male') maleCount++;
          if (user['gender'] == 'female') femaleCount++;
        }

        return [
          PieChartData(category: 'Male', value: maleCount),
          PieChartData(category: 'Female', value: femaleCount),
        ];
      } else {
        throw Exception('Failed to fetch gender data');
      }
    } catch (e) {
      print(e);
      throw Exception('Error fetching gender data');
    }
  }


  Future<List<Map<String, dynamic>>> fetchTopViewedBooks() async {
    const String url = 'https://readme-backend-zdiq.onrender.com/api/v1/books/all';
    const String token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3MzkzMDZjZDU0OTI2NDI5ODg4MTY0ZCIsImlzQWRtaW4iOnRydWUsImlhdCI6MTczMzM4MzMyMCwiZXhwIjoxNzQxMTU5MzIwfQ.Lzl05Sx4-xm0DCUVPPPAQUtr6A2WB6gk4CXoQd1L8ro'; // Replace with your admin token
    List<Map<String, dynamic>> topBooks = [];

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> books = data['books'];

        // Sort books by views and get the top 5
        final sortedBooks = books
            .where((book) => book['isVisible'] == true)
            .toList()
          ..sort((a, b) => b['numberOfViews'].compareTo(a['numberOfViews']));

        topBooks = sortedBooks.take(5).map((book) {
          return {
            'title': book['title'],
            'views': book['numberOfViews'],
          };
        }).toList();
      } else {
        print('Failed to fetch books. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching books: $error');
    }

    return topBooks;
  }



  Future<void> fetchTransactionTypeCounts() async {
    final String url =
        'https://readme-backend-zdiq.onrender.com/api/v1/transactions/admin/all?&status=COMPLETED&startDate=2024-01-01&endDate=2025-12-31&limit=100&page=1';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3MzkzMDZjZDU0OTI2NDI5ODg4MTY0ZCIsImlzQWRtaW4iOnRydWUsImlhdCI6MTczMzM4MzMyMCwiZXhwIjoxNzQxMTU5MzIwfQ.Lzl05Sx4-xm0DCUVPPPAQUtr6A2WB6gk4CXoQd1L8ro',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> transactions = data['transactions'];

        int purchaseCount = 0;
        int subscriptionCount = 0;

        for (var transaction in transactions) {
          String type = transaction['type'];
          if (type == 'BOOK_PURCHASE') {
            purchaseCount++;
          } else if (type == 'SUBSCRIPTION') {
            subscriptionCount++;
          }
        }

        setState(() {
          transactionTypeCounts = {
            'BOOK_PURCHASE': purchaseCount,
            'SUBSCRIPTION': subscriptionCount,
          };
        });
      } else {
        print('Failed to fetch transaction types. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching transaction types: $error');
    }
  }

  Future<void> fetchTransactionCount() async {
    final url =
        'https://readme-backend-zdiq.onrender.com/api/v1/transactions/admin/all?&status=COMPLETED&startDate=2024-01-01&endDate=2025-12-31&limit=100&page=1';

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

  Future<List<Map<String, dynamic>>> fetchTopReportedBooks() async {
    const String url = 'https://readme-backend-zdiq.onrender.com/api/v1/books/:bookId/reports';
    const String token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3MzkzMDZjZDU0OTI2NDI5ODg4MTY0ZCIsImlzQWRtaW4iOnRydWUsImlhdCI6MTczMzM4MzMyMCwiZXhwIjoxNzQxMTU5MzIwfQ.Lzl05Sx4-xm0DCUVPPPAQUtr6A2WB6gk4CXoQd1L8ro'; // Replace with your admin token
    List<Map<String, dynamic>> bookReports = [];

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> reports = data['reports'];

        // Count reports per book
        Map<String, int> reportCounts = {};
        Map<String, String> bookTitles = {};

        for (var report in reports) {
          final bookId = report['book']['_id'];
          final bookTitle = report['book']['title'];
          reportCounts[bookId] = (reportCounts[bookId] ?? 0) + 1;
          bookTitles[bookId] = bookTitle;
        }

        // Sort by report count and get top 3
        final sortedBooks = reportCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        bookReports = sortedBooks.take(3).map((entry) {
          return {
            'bookId': entry.key,
            'title': bookTitles[entry.key] ?? 'Unknown Title',
            'count': entry.value,
          };
        }).toList();
      } else {
        print('Failed to fetch reports. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching reports: $error');
    }

    return bookReports;
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
          'Authorization': 'Bearer $token', 
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
              // Count Cards Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CategoryCountCard(categoryCount: categoryCount),
                  AuthorCountCard(authorCount: authorCount),
                  BookCountCard(bookCount: bookCount),
                  TransactionCountCard(transactionCount: transactionCount),
                  ReviewCountCard(reviewCount: reviewCount),
                  ReportCountCard(reportCount: reportCount),
                  UserCountCard(userCount: userCount),
                ],
              ),
              SizedBox(height: 30),

              // Gender Distribution Chart Section
              SectionTitle(title: 'Gender Distribution'),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: FutureBuilder<List<PieChartData>>(
                  future: fetchGenderData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error loading data'));
                    } else if (snapshot.hasData) {
                      final data = snapshot.data!;
                      return SfCircularChart(
                        title: ChartTitle(
                          text: 'Gender Distribution',
                          textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        legend: Legend(
                          isVisible: true,
                          overflowMode: LegendItemOverflowMode.wrap,
                          position: LegendPosition.bottom,
                        ),
                        series: <CircularSeries>[
                          PieSeries<PieChartData, String>(
                            dataSource: data,
                            xValueMapper: (PieChartData data, _) => data.category,
                            yValueMapper: (PieChartData data, _) => data.value,
                            dataLabelSettings: DataLabelSettings(isVisible: true),
                          ),
                        ],
                      );
                    } else {
                      return Center(child: Text('No data available'));
                    }
                  },
                ),
              ),
              SizedBox(height: 30),

              // Top Viewed Books Chart Section
              SectionTitle(title: 'Top 5 Most Viewed Books'),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: fetchTopViewedBooks(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error loading data'));
                    } else if (snapshot.hasData) {
                      final topBooks = snapshot.data!;
                      return SfCartesianChart(
                        primaryXAxis: CategoryAxis(
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          majorGridLines: MajorGridLines(width: 0),
                        ),
                        primaryYAxis: NumericAxis(
                          labelStyle: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                          majorGridLines: MajorGridLines(
                            dashArray: [5, 5],
                            color: Colors.grey.withOpacity(0.5),
                          ),
                        ),
                        title: ChartTitle(
                          text: 'Top 5 Most Viewed Books',
                          textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        tooltipBehavior: TooltipBehavior(
                          enable: true,
                          header: '',
                          canShowMarker: false,
                        ),
                        series: <ChartSeries>[
                          ColumnSeries<Map<String, dynamic>, String>(
                            dataSource: topBooks,
                            xValueMapper: (Map<String, dynamic> data, _) =>
                            data['title'],
                            yValueMapper: (Map<String, dynamic> data, _) =>
                            data['views'],
                            name: 'Views',
                            dataLabelSettings: DataLabelSettings(
                              isVisible: true,
                              textStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            color: Color(0xFF5AA5B1),
                          ),
                        ],
                        plotAreaBorderWidth: 0,
                      );
                    } else {
                      return Center(child: Text('No data available'));
                    }
                  },
                ),
              ),
              SizedBox(height: 30),

              // Transaction Types Chart Section
              SectionTitle(title: 'Transaction Type Overview'),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    majorGridLines: MajorGridLines(width: 0),
                  ),
                  primaryYAxis: NumericAxis(
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                    majorGridLines: MajorGridLines(
                      dashArray: [5, 5],
                      color: Colors.grey.withOpacity(0.5),
                    ),
                  ),
                  title: ChartTitle(
                    text: 'Transaction Types',
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  tooltipBehavior: TooltipBehavior(
                    enable: true,
                    header: '',
                    canShowMarker: false,
                  ),
                  series: <ChartSeries>[
                    ColumnSeries<MapEntry<String, int>, String>(
                      dataSource: transactionTypeCounts.entries.toList(),
                      xValueMapper: (MapEntry<String, int> data, _) => data.key,
                      yValueMapper: (MapEntry<String, int> data, _) => data.value,
                      name: 'Transactions',
                      dataLabelSettings: DataLabelSettings(
                        isVisible: true,
                        textStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      color: Color(0xFF5AA5B1),
                    ),
                  ],
                  plotAreaBorderWidth: 0,
                ),
              ),
              SizedBox(height: 30),

              // Top Reported Books Chart Section
              SectionTitle(title: 'Top 3 Reported Books'),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: fetchTopReportedBooks(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error loading data'));
                    } else if (snapshot.hasData) {
                      final bookReports = snapshot.data!;
                      return SfCartesianChart(
                        primaryXAxis: CategoryAxis(
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          majorGridLines: MajorGridLines(width: 0),
                        ),
                        primaryYAxis: NumericAxis(
                          labelStyle: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                          majorGridLines: MajorGridLines(
                            dashArray: [5, 5],
                            color: Colors.grey.withOpacity(0.5),
                          ),
                        ),
                        title: ChartTitle(
                          text: 'Top 3 Reported Books',
                          textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        tooltipBehavior: TooltipBehavior(
                          enable: true,
                          header: '',
                          canShowMarker: false,
                        ),
                        series: <ChartSeries>[
                          ColumnSeries<Map<String, dynamic>, String>(
                            dataSource: bookReports,
                            xValueMapper: (Map<String, dynamic> data, _) =>
                            data['title'],
                            yValueMapper: (Map<String, dynamic> data, _) =>
                            data['count'],
                            name: 'Reports',
                            dataLabelSettings: DataLabelSettings(
                              isVisible: true,
                              textStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            color: Color(0xFF5AA5B1),
                          ),
                        ],
                        plotAreaBorderWidth: 0,
                      );
                    } else {
                      return Center(child: Text('No data available'));
                    }
                  },
                ),
              ),
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
class PieChartData {
  final String category; // e.g., "Male", "Female"
  final int value; // e.g., number of users

  PieChartData({required this.category, required this.value});
}

