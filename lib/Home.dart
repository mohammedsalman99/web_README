import 'package:flutter/material.dart';
import 'package:web_frontend/screens/authors.dart';
import 'package:web_frontend/screens/books.dart';
import 'package:web_frontend/screens/categories.dart';
import 'package:web_frontend/screens/chat_page.dart';
import 'package:web_frontend/screens/dashboard.dart';
import 'package:web_frontend/screens/notification_send.dart';
import 'package:web_frontend/screens/pages.dart';
import 'package:web_frontend/screens/payment_gateway.dart';
import 'package:web_frontend/screens/reports.dart';
import 'package:web_frontend/screens/reviews.dart';
import 'package:web_frontend/screens/settings.dart';
import 'package:web_frontend/screens/subscription_plan.dart';
import 'package:web_frontend/screens/transactions.dart';
import 'package:web_frontend/screens/users.dart';
import 'package:web_frontend/screens/chat_service.dart'; // Chat service to handle API requests

class Home extends StatefulWidget {
  final String fullName;
  final String email;
  final String profilePicture;

  const Home({
    Key? key,
    required this.fullName,
    required this.email,
    required this.profilePicture,
  }) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  final Color primaryColor = const Color(0xFF5AA5B1);
  final Color secondaryColor = const Color(0xFF3D7A8A);
  final Color highlightColor = const Color(0xFFEDF7F9);

  final List<Widget> _pages = [
    DashboardPage(),
    CategoriesPage(),
    AuthorsPage(),
    BooksPage(),
    UsersPage(),
    SubscriptionPlanPage(),
    PaymentGatewayPage(),
    TransactionTable(),
    AllReviewsPage(),
    ReportsPage(),
    PagesPage(),
    NotificationsPage(),
    SettingsPage(),
    ChatPage(), // Add ChatPage here
  ];

  final List<String> _titles = [
    'Dashboard',
    'Categories',
    'Authors',
    'Books',
    'Users',
    'Subscription Plan',
    'Payment Gateway',
    'Transactions',
    'Reviews',
    'Reports',
    'Pages',
    'Notification Send',
    'Settings',
    'Chat', // Add Chat title here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(widget.profilePicture),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.fullName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.email,
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: primaryColor,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications.')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              setState(() {
                _currentIndex = 12;
              });
            },
          ),
        ],
      ),
      body: Row(
        children: [
          _buildSideNavigationBar(context),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _pages[_currentIndex],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
    );
  }

  Widget _buildSideNavigationBar(BuildContext context) {
    return Container(
      width: 250,
      color: primaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView(
              children: List.generate(_titles.length, (index) {
                return _buildDrawerItem(
                  context,
                  _getIconForIndex(index),
                  _titles[index],
                  index,
                );
              }),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(
        icon,
        color: _currentIndex == index ? highlightColor : Colors.white,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: _currentIndex == index ? highlightColor : Colors.white,
          fontWeight:
          _currentIndex == index ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: _currentIndex == index ? secondaryColor : Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
    );
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.dashboard;
      case 1:
        return Icons.category;
      case 2:
        return Icons.person;
      case 3:
        return Icons.book;
      case 4:
        return Icons.group;
      case 5:
        return Icons.subscriptions;
      case 6:
        return Icons.payment;
      case 7:
        return Icons.receipt_long;
      case 8:
        return Icons.feedback;
      case 9:
        return Icons.report;
      case 10:
        return Icons.pages;
      case 11:
        return Icons.notifications;
      case 12:
        return Icons.settings;
      case 13:
        return Icons.chat; // Add chat icon
      default:
        return Icons.home;
    }
  }
}

