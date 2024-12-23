import 'package:flutter/material.dart';

class PagesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pages'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Text(
          'Pages Content Goes Here',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
