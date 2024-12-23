import 'package:flutter/material.dart';

class PaymentGatewayPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Gateway'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Text(
          'Payment Gateway Content Goes Here',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
