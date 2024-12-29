import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TransactionsPage extends StatefulWidget {
  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  List transactions = [];
  bool isLoading = true;
  int currentPage = 1;
  int totalPages = 1;

  final String apiUrl =
      "https://readme-backend-zdiq.onrender.com/api/v1/transactions/admin/all";
  final String adminToken =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3MzkzMDZjZDU0OTI2NDI5ODg4MTY0ZCIsImlzQWRtaW4iOnRydWUsImlhdCI6MTczMzM4MzMyMCwiZXhwIjoxNzQxMTU5MzIwfQ.Lzl05Sx4-xm0DCUVPPPAQUtr6A2WB6gk4CXoQd1L8ro";

  @override
  void initState() {
    super.initState();
    fetchTransactions(page: currentPage);
  }

  Future<void> fetchTransactions({required int page}) async {
    setState(() {
      isLoading = true;
    });

    final queryParameters = {
      "type": "SUBSCRIPTION",
      "status": "COMPLETED",
      "startDate": "2024-01-01",
      "endDate": "2025-12-31",
      "limit": "10",
      "page": "$page",
    };

    try {
      final uri = Uri.parse(apiUrl).replace(queryParameters: queryParameters);
      final response = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $adminToken",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          transactions = data['transactions'];
          currentPage = data['pagination']['page'];
          totalPages = data['pagination']['pages'];
          isLoading = false;
        });
      } else {
        print('Failed to fetch transactions: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching transactions: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void handlePagination(int newPage) {
    if (newPage > 0 && newPage <= totalPages) {
      fetchTransactions(page: newPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1A202C),
        title: Text(
          "Transactions",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      )
          : Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.resolveWith<Color>(
                      (states) => Color(0xFF2D3748),
                ),
                dataRowColor: MaterialStateProperty.resolveWith<Color>(
                      (states) => Colors.black,
                ),
                columns: [
                  DataColumn(
                    label: Text(
                      'Name',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Email',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Plan',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Amount',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Payment Method',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Payment Date',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: transactions.map((transaction) {
                  return DataRow(
                    cells: [
                      DataCell(Text(
                        transaction['user']['fullName'] ?? 'N/A',
                        style: TextStyle(color: Colors.white),
                      )),
                      DataCell(Text(
                        transaction['user']['email'] ?? 'N/A',
                        style: TextStyle(color: Colors.white),
                      )),
                      DataCell(Text(
                        transaction['paymentGateway']['metadata']['planId'] ??
                            'N/A',
                        style: TextStyle(color: Colors.white),
                      )),
                      DataCell(Text(
                        '\$${transaction['amount']}',
                        style: TextStyle(color: Colors.white),
                      )),
                      DataCell(Text(
                        transaction['paymentMethod'] ?? 'N/A',
                        style: TextStyle(color: Colors.white),
                      )),
                      DataCell(Text(
                        transaction['paymentDate'] ?? 'N/A',
                        style: TextStyle(color: Colors.white),
                      )),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: 10),
          PaginationControls(
            currentPage: currentPage,
            totalPages: totalPages,
            onPageChanged: handlePagination,
          ),
        ],
      ),
    );
  }
}

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  const PaginationControls({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
        ),
        Text(
          "$currentPage of $totalPages",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: Icon(Icons.arrow_forward, color: Colors.white),
          onPressed: currentPage < totalPages
              ? () => onPageChanged(currentPage + 1)
              : null,
        ),
      ],
    );
  }
}
