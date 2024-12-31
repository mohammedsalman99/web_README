import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
    home: TransactionTable(),
    debugShowCheckedModeBanner: false,
  ));
}

class TransactionTable extends StatefulWidget {
  @override
  _TransactionTableState createState() => _TransactionTableState();
}

class _TransactionTableState extends State<TransactionTable> {
  final String token =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3MzkzMDZjZDU0OTI2NDI5ODg4MTY0ZCIsImlzQWRtaW4iOnRydWUsImlhdCI6MTczMzM4MzMyMCwiZXhwIjoxNzQxMTU5MzIwfQ.Lzl05Sx4-xm0DCUVPPPAQUtr6A2WB6gk4CXoQd1L8ro';

  int currentPage = 1;
  final TextEditingController searchController = TextEditingController();
  List<dynamic> filteredTransactions = [];

  int totalPages = 1;
  int rowsPerPage = 15;
  List<dynamic> transactions = [];
  Map<int, List<dynamic>> transactionCache = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchAndSetTransactions();
  }

  Future<void> fetchAndSetTransactions({int? page}) async {
    final int fetchPage = page ?? currentPage;

    if (transactionCache.containsKey(fetchPage)) {
      setState(() {
        transactions = transactionCache[fetchPage]!;
        filteredTransactions = transactions;
        currentPage = fetchPage;
      });
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final data = await fetchTransactions(
        token: token,
        page: fetchPage,
        limit: rowsPerPage,
      );

      setState(() {
        transactions = data['transactions'];
        filteredTransactions = transactions; 
        totalPages = (data['pagination']['total'] / rowsPerPage).ceil();
        currentPage = fetchPage;
        transactionCache[fetchPage] = transactions;
      });
    } catch (e) {
      print('Error fetching transactions: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  void filterTransactions(String query) {
    setState(() {
      filteredTransactions = transactions
          .where((transaction) =>
      (transaction['user']?['fullName']?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
          (transaction['type']?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
          (transaction['amount']?.toString().contains(query) ?? false) ||
          (transaction['paymentDate']?.toLowerCase().contains(query.toLowerCase()) ?? false))
          .toList();
    });
  }

  Future<Map<String, dynamic>> fetchTransactions({
    required String token,
    required int page,
    required int limit,
  }) async {
    final String transactionsUrl = 'api/v1/transactions';
    final url =
        'https://readme-backend-zdiq.onrender.com/$transactionsUrl/admin/all?status=COMPLETED&startDate=2024-01-01&endDate=2025-12-31&limit=$limit&page=$page';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load transactions');
    }
  }

  void _nextPage() {
    if (currentPage < totalPages && !isLoading) {
      fetchAndSetTransactions(page: currentPage + 1);
    }
  }

  void _previousPage() {
    if (currentPage > 1 && !isLoading) {
      fetchAndSetTransactions(page: currentPage - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Search Transactions',
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
                onChanged: filterTransactions, 
              ),
            ),
            Expanded(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.565,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: const Offset(0, 4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: isLoading
                      ? const Center(
                    child: CircularProgressIndicator(),
                  )
                      : filteredTransactions.isEmpty
                      ? const Center(
                    child: Text(
                      'No transactions found',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                      ),
                    ),
                  )
                      : SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                            const Color(0xFFB2EBF2)),
                        columnSpacing: 40,
                        columns: const [
                          DataColumn(
                            label: Text(
                              '#',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 22,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'User',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 22,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Type',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 22,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Amount',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 22,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Status',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 22,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Date',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 22,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Method',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ],
                        rows: filteredTransactions.asMap().entries.map((entry) {
                          int index = entry.key + 1 + (currentPage - 1) * rowsPerPage;
                          var transaction = entry.value;

                          return DataRow(
                            color: WidgetStateProperty.resolveWith<Color>(
                                  (Set<WidgetState> states) {
                                if (states.contains(WidgetState.hovered)) {
                                  return const Color(0xFFE0F7FA);
                                }
                                return index % 2 == 0 ? Colors.white : const Color(0xFFF5F5F5);
                              },
                            ),
                            cells: [
                              DataCell(Text(
                                '$index',
                                style: const TextStyle(fontSize: 16),
                              )),
                              DataCell(Text(
                                transaction['user']?['fullName'] ?? 'Unknown User',
                                style: const TextStyle(fontSize: 18),
                              )),
                              DataCell(Text(
                                transaction['type'] ?? 'N/A',
                                style: const TextStyle(fontSize: 18),
                              )),
                              DataCell(Text(
                                '\$${transaction['amount'] ?? 0}',
                                style: const TextStyle(fontSize: 18),
                              )),
                              DataCell(
                                Chip(
                                  label: Text(
                                    transaction['status'] ?? 'Unknown',
                                    style: const TextStyle(color: Colors.white, fontSize: 16),
                                  ),
                                  backgroundColor: transaction['status'] == 'COMPLETED'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              DataCell(Text(
                                transaction['paymentDate']?.split('T')[0] ?? 'Unknown Date',
                                style: const TextStyle(fontSize: 18),
                              )),
                              DataCell(Text(
                                transaction['paymentMethod'] ?? 'Unknown Method',
                                style: const TextStyle(fontSize: 18),
                              )),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Page $currentPage of $totalPages',
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: currentPage > 1 && !isLoading ? _previousPage : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentPage > 1
                            ? const Color(0xFFB2EBF2)
                            : Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Text(
                        'Previous',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: currentPage < totalPages && !isLoading ? _nextPage : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentPage < totalPages
                            ? const Color(0xFFB2EBF2)
                            : Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Text(
                        'Next',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


}
