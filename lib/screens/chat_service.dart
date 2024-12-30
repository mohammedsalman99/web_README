import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  final String baseUrl = "https://readme-backend-zdiq.onrender.com/api/v1/chat";
  final String adminToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3MzkzMDZjZDU0OTI2NDI5ODg4MTY0ZCIsImlzQWRtaW4iOnRydWUsImlhdCI6MTczMzM4MzMyMCwiZXhwIjoxNzQxMTU5MzIwfQ.Lzl05Sx4-xm0DCUVPPPAQUtr6A2WB6gk4CXoQd1L8ro"; // Replace with your admin token

  Map<String, String> get headers => {
    "Content-Type": "application/json",
    "Authorization": "Bearer $adminToken",
  };

  Future<bool> sendMessageToUser(String userEmail, String message) async {
    final url = Uri.parse("$baseUrl/send");
    final body = jsonEncode({
      "message": message,
      "userEmail": userEmail, 
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print("Message sent successfully: ${response.body}");
        return true;
      } else {
        print("Failed to send message: ${response.statusCode} ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error sending message: $e");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getUserMessages(String userEmail) async {
    final url = Uri.parse("$baseUrl/messages/$userEmail");

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['messages']);
      } else {
        print("Failed to fetch messages: ${response.statusCode} ${response.body}");
        return [];
      }
    } catch (e) {
      print("Error fetching user messages: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllChats() async {
    final url = Uri.parse("$baseUrl/all");

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['chats']);
      } else {
        print("Failed to fetch chats: ${response.statusCode} ${response.body}");
        return [];
      }
    } catch (e) {
      print("Error fetching chats: $e");
      return [];
    }
  }
}
