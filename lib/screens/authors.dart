import 'package:flutter/material.dart';

class AuthorsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Authors'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Text(
          'Authors Content Goes Here',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
