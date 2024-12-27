import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReportsPage extends StatefulWidget {
  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  static const String apiUrl =
      'https://readme-backend-zdiq.onrender.com/api/v1/books/:bookId/reports';
  static const String adminToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3MzkzMDZjZDU0OTI2NDI5ODg4MTY0ZCIsImlzQWRtaW4iOnRydWUsImlhdCI6MTczMzM4MzMyMCwiZXhwIjoxNzQxMTU5MzIwfQ.Lzl05Sx4-xm0DCUVPPPAQUtr6A2WB6gk4CXoQd1L8ro';

  static const int pageSize = 4; // Show 4 reports per scroll chunk
  List<Map<String, dynamic>> _allReports = []; // Store all reports
  bool _isLoading = false;
  int _currentChunk = 1;
  int _totalChunks = 0; // Dynamically calculate based on allReports.length

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchReports();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent &&
          !_isLoading &&
          _currentChunk < _totalChunks) {
        _loadMoreReports();
      }
    });
  }
  void _searchBooks(String query) {
    setState(() {
      // If the search query is empty, reset to show all reports
      if (query.isEmpty) {
        _fetchReports();  // Fetch and show all reports again
      } else {
        // Filter the reports based on book title
        _allReports = _allReports.where((report) {
          final bookTitle = report['book']['title'].toLowerCase();
          final searchQuery = query.toLowerCase();
          return bookTitle.contains(searchQuery); // Check if book title matches the query
        }).toList();
      }
    });
  }


  Future<void> _updateReportStatus(String bookId, String reportId) async {
    final String url = 'https://readme-backend-zdiq.onrender.com/api/v1/books/$bookId/reports/$reportId/status';

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $adminToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'status': 'reviewed', // Set status to "reviewed"
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}'); // Log the response body for debugging

      if (response.statusCode == 200) {
        // Successfully updated status, you can refresh the reports or update UI
        setState(() {
          // Update the status locally
          final reportIndex = _allReports.indexWhere((report) => report['_id'] == reportId);
          if (reportIndex != -1) {
            _allReports[reportIndex]['status'] = 'reviewed';
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report status updated to "Reviewed"')),
        );
      } else {
        // Handle failure
        print('Error: Failed to update status, status code: ${response.statusCode}');
        print('Error body: ${response.body}'); // Log the error body for debugging
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: ${response.statusCode}')),
        );
      }
    } catch (e) {
      // Catch and print any errors during the API request
      print('Error occurred while updating status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred: $e')),
      );
    }
  }


  Future<void> _fetchReports() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $adminToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<Map<String, dynamic>> allReports =
        List<Map<String, dynamic>>.from(data['reports'] ?? []);

        setState(() {
          _allReports = allReports;
          _totalChunks = (_allReports.length / pageSize).ceil();
        });
      } else {
        throw Exception('Failed to load reports: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading reports: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  /// Loads the next chunk of reports when scrolling reaches the bottom.
  void _loadMoreReports() {
    if (_currentChunk >= _totalChunks) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate chunk loading (already fetched reports are paginated locally)
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _currentChunk++;
        _isLoading = false;
      });
    });
  }

  List<Map<String, dynamic>> get _visibleReports {
    final startIndex = 0;
    final endIndex = _currentChunk * pageSize;
    return _allReports.sublist(
      startIndex,
      endIndex > _allReports.length ? _allReports.length : endIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            onChanged: _searchBooks,  // Trigger search in books on text change
            decoration: InputDecoration(
              hintText: 'Search books...',
              hintStyle: TextStyle(color: Colors.grey),
              prefixIcon: Icon(Icons.search, color: Colors.teal),
              border: InputBorder.none,
            ),
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),


      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _allReports.clear();
            _currentChunk = 1;
            _totalChunks = 0;
          });
          await _fetchReports(); // Fetch reports from the backend when refreshing
        },
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _allReports.length + 1,
          itemBuilder: (context, index) {
            if (index == _allReports.length) {
              return _isLoading
                  ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              )
                  : SizedBox.shrink();
            }
            return _buildReportCard(_allReports[index]);
          },
        ),
      ),
    );
  }


  Widget _buildReportCard(Map<String, dynamic> report) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB2DFDB), Color(0xFFE0F2F1)], // Teal shades
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF80CBC4).withOpacity(0.5),
              offset: Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: User Info and Date
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Enhanced Circle Avatar
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF4DB6AC).withOpacity(0.3),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white,
                      child: Text(
                        report['user']['fullName'][0].toUpperCase(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Color(0xFF00796B)),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report['user']['fullName'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF00796B),
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.email, size: 16, color: Colors.grey),
                            SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                report['user']['email'],
                                style:
                                TextStyle(fontSize: 14, color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Creation Date
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Icon(Icons.calendar_today,
                          size: 20, color: Color(0xFF00796B)),
                      SizedBox(height: 4),
                      Text(
                        _formatDate(report['createdAt']),
                        style: TextStyle(
                            fontSize: 12, color: Color(0xFF00796B)),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Book Title
              Row(
                children: [
                  Icon(Icons.book, size: 20, color: Color(0xFF00897B)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      report['book']['title'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF004D40),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),

              // Advanced UX for Report Text
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        report['description'],
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF004D40),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Action Buttons: "Delete" and "Review"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Delete Button
                  ElevatedButton.icon(
                    onPressed: () {
                      // Action for Delete
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFE57373),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    icon: Icon(Icons.delete, size: 18),
                    label: Text('Delete'),
                  ),

                  // Review Button
                  ElevatedButton.icon(
                    onPressed: () {
                      _updateReportStatus(report['book']['_id'], report['_id']);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent, // Blue color for "Review"
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    icon: Icon(Icons.check, size: 18),
                    label: Text('Review'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  /// Helper function to format the date
  String _formatDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    return "${parsedDate.day}-${parsedDate.month}-${parsedDate.year}";
  }



  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class Badge extends StatelessWidget {
  final String status;

  const Badge({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color badgeColor =
    status == 'pending' ? Colors.orange : Colors.greenAccent;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
