import 'package:flutter/material.dart';

class SubscriptionPlanPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subscription Plan'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Text(
          'Subscription Plan Content Goes Here',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
