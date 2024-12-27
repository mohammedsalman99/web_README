import 'package:flutter/material.dart';
import 'package:web_frontend/screens/login_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login', // Directly go to the login page
      routes: {
        '/login': (context) => LoginPage(),  // Navigate to the login page
      },
    );
  }
}
