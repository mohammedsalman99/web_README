import 'package:flutter/material.dart';
import 'package:web_frontend/screens/login_page.dart';
import 'package:web_frontend/screens/splash_screen.dart';
// Replace with your actual login screen file

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashScreen(),
        '/login': (context) => LoginPage(), 
      },
    );
  }
}
