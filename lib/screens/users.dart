import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserScreen extends StatefulWidget {
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  List<dynamic> users = [];
  List<dynamic> filteredUsers = [];
  bool isLoading = true;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final url = 'https://readme-backend-zdiq.onrender.com/api/v1/users/all';
    final headers = {'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3MzkzMDZjZDU0OTI2NDI5ODg4MTY0ZCIsImlzQWRtaW4iOnRydWUsImlhdCI6MTczMzM4MzMyMCwiZXhwIjoxNzQxMTU5MzIwfQ.Lzl05Sx4-xm0DCUVPPPAQUtr6A2WB6gk4CXoQd1L8ro'};
    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          users = data['users'];
          filteredUsers = users; // Initially, show all users
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterUsers(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredUsers = users;
      });
    } else {
      setState(() {
        filteredUsers = users
            .where((user) =>
            user['fullName'].toString().toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'User Management',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFB2EBF2),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText: 'Search by name',
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFB2EBF2), width: 2.0),
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              onChanged: filterUsers,
            ),
          ),
          // User List
          isLoading
              ? Expanded(
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFFB2EBF2)),
              ),
            ),
          )
              : Expanded(
            child: ListView.builder(
              itemCount: filteredUsers.length,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  color: Color(0xFFB2EBF2),
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Picture
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                            user['profilePicture'] ?? '',
                          ),
                          radius: 30,
                          backgroundColor: Colors.white,
                        ),
                        SizedBox(width: 16),
                        // User Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user['fullName'] ?? 'No Name',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Email: ${user['email']}',
                                style: TextStyle(color: Colors.black54),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Phone: ${user['phoneNumber']}',
                                style: TextStyle(color: Colors.black54),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Gender: ${user['gender']}',
                                style: TextStyle(color: Colors.black54),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Admin: ${user['isAdmin'] ? 'Yes' : 'No'}',
                                style: TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        // Action Buttons
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () =>
                                  showUpdateDialog(user['_id'], user),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteUser(user['_id']),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  void showUpdateDialog(String userId, Map<String, dynamic> user) {
    final TextEditingController fullNameController =
    TextEditingController(text: user['fullName']);
    final TextEditingController emailController =
    TextEditingController(text: user['email']);
    final TextEditingController phoneNumberController =
    TextEditingController(text: user['phoneNumber']);
    final TextEditingController profilePictureController =
    TextEditingController(text: user['profilePicture']);
    final bool isAdmin = user['isAdmin'];
    final bool isVerified = user['isVerified'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Update User'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: fullNameController,
                    decoration: InputDecoration(labelText: 'Full Name'),
                  ),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                  TextField(
                    controller: phoneNumberController,
                    decoration: InputDecoration(labelText: 'Phone Number'),
                  ),
                  TextField(
                    controller: profilePictureController,
                    decoration: InputDecoration(labelText: 'Profile Picture URL'),
                  ),
                  SwitchListTile(
                    title: Text('Is Admin'),
                    value: isAdmin,
                    onChanged: (value) {
                      setState(() {
                        user['isAdmin'] = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: Text('Is Verified'),
                    value: isVerified,
                    onChanged: (value) {
                      setState(() {
                        user['isVerified'] = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final updatedData = {
                    'fullName': fullNameController.text,
                    'email': emailController.text,
                    'phoneNumber': phoneNumberController.text,
                    'profilePicture': profilePictureController.text,
                    'isAdmin': user['isAdmin'],
                    'isVerified': user['isVerified'],
                  };
                  updateUser(userId, updatedData);
                  Navigator.pop(context);
                },
                child: Text('Update'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> updateUser(String userId, Map<String, dynamic> updatedData) async {
    final url = 'https://readme-backend-zdiq.onrender.com/api/v1/users/$userId';
    final headers = {
      'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3MzkzMDZjZDU0OTI2NDI5ODg4MTY0ZCIsImlzQWRtaW4iOnRydWUsImlhdCI6MTczMzM4MzMyMCwiZXhwIjoxNzQxMTU5MzIwfQ.Lzl05Sx4-xm0DCUVPPPAQUtr6A2WB6gk4CXoQd1L8ro',
      'Content-Type': 'application/json',
    };
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: json.encode(updatedData),
      );
      if (response.statusCode == 200) {
        final updatedUser = json.decode(response.body)['user'];
        setState(() {
          final index = users.indexWhere((user) => user['_id'] == userId);
          if (index != -1) users[index] = updatedUser;
          filterUsers(searchController.text); // Re-filter after update
        });
      } else {
        throw Exception('Failed to update user');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteUser(String userId) async {
    final url = 'https://readme-backend-zdiq.onrender.com/api/v1/users/$userId';
    final headers = {'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3MzkzMDZjZDU0OTI2NDI5ODg4MTY0ZCIsImlzQWRtaW4iOnRydWUsImlhdCI6MTczMzM4MzMyMCwiZXhwIjoxNzQxMTU5MzIwfQ.Lzl05Sx4-xm0DCUVPPPAQUtr6A2WB6gk4CXoQd1L8ro'};
    try {
      final response = await http.delete(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        setState(() {
          users.removeWhere((user) => user['_id'] == userId);
          filterUsers(searchController.text); // Re-filter after delete
        });
      } else {
        throw Exception('Failed to delete user');
      }
    } catch (e) {
      print(e);
    }
  }
}
