import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final String _adminToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3MzkzMDZjZDU0OTI2NDI5ODg4MTY0ZCIsImlzQWRtaW4iOnRydWUsImlhdCI6MTczMzM4MzMyMCwiZXhwIjoxNzQxMTU5MzIwfQ.Lzl05Sx4-xm0DCUVPPPAQUtr6A2WB6gk4CXoQd1L8ro'; // Replace with the actual admin token
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _body = '';
  String _imageUrl = '';
  String _endpoint = 'send/all'; // Default endpoint
  String _responseMessage = '';

  Future<void> _sendNotification() async {
    try {
      print("Preparing to send notification...");
      final String baseUrl = 'https://readme-backend-zdiq.onrender.com/api/v1/notifications';
      final url = Uri.parse('$baseUrl/$_endpoint');
      final payload = {
        "title": _title,
        "body": _body,
        "data": {
          "type": "custom_notification",
          "actionUrl": "/custom-action",
        },
        if (_imageUrl.isNotEmpty) "imageUrl": _imageUrl,
      };

      print("Payload: ${jsonEncode(payload)}");
      print("URL: $url");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_adminToken',
        },
        body: jsonEncode(payload),
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _responseMessage = data['message'];
        });
        print("Notification sent successfully: ${data['message']}");
      } else {
        setState(() {
          _responseMessage = 'Error: ${response.statusCode} - ${response.body}';
        });
        print("Failed to send notification. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        _responseMessage = 'Failed to send notification: $e';
      });
      print("Error while sending notification: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _endpoint,
                onChanged: (value) {
                  setState(() {
                    _endpoint = value!;
                  });
                  print("Endpoint changed to: $_endpoint");
                },
                items: [
                  DropdownMenuItem(
                    value: 'send/all',
                    child: Text('Send to All Users'),
                  ),
                  DropdownMenuItem(
                    value: 'send/free-users',
                    child: Text('Send to Free Users'),
                  ),
                  DropdownMenuItem(
                    value: 'send/subscribed-users',
                    child: Text('Send to Subscribed Users'),
                  ),
                ],
                decoration: InputDecoration(labelText: 'Notification Target'),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Title'),
                onChanged: (value) => _title = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Body'),
                onChanged: (value) => _body = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Body is required';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Image URL (Optional)'),
                onChanged: (value) => _imageUrl = value,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    print("Form validated. Sending notification...");
                    _sendNotification();
                  } else {
                    print("Form validation failed.");
                  }
                },
                child: const Text('Send Notification'),
              ),
              const SizedBox(height: 20),
              if (_responseMessage.isNotEmpty)
                Text(
                  _responseMessage,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
