import 'dart:typed_data';
import 'dart:html' as html; // For Flutter Web
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

class CreateCategoryPage extends StatefulWidget {
  @override
  _CreateCategoryPageState createState() => _CreateCategoryPageState();
}

class _CreateCategoryPageState extends State<CreateCategoryPage> {
  final TextEditingController _titleController = TextEditingController();
  Uint8List? _selectedImage; // Store the image as bytes
  bool _isVisible = true; // Default value for visibility

  // Method to pick an image using HTML File Upload (Flutter Web)
  Future<void> _pickImage() async {
    final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*'; // Restrict file type to images
    uploadInput.click();

    uploadInput.onChange.listen((e) async {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(files[0]); // Read file as bytes

        reader.onLoadEnd.listen((event) {
          setState(() {
            _selectedImage = reader.result as Uint8List; // Store the image bytes
          });
        });
      }
    });
  }

  // Method to create the category
  Future<void> _createCategory() async {
    final String title = _titleController.text.trim();
    if (title.isEmpty || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please provide a title and select an image')),
      );
      return;
    }

    final url = 'https://readme-backend-zdiq.onrender.com/api/v1/categories';
    final token =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3MzkzMDZjZDU0OTI2NDI5ODg4MTY0ZCIsImlzQWRtaW4iOnRydWUsImlhdCI6MTczNTMxMTE5MiwiZXhwIjoxNzQzMDg3MTkyfQ.lzAlViNODQWPGtjJ8cEBKK6zLzWcItpBmf5N5aD0laY';

    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['Authorization'] = 'Bearer $token';

      // Add fields
      request.fields['title'] = title;

      // Attach the image as bytes
      final imageFileBytes = http.MultipartFile.fromBytes(
        'image', // Field name must match the API
        _selectedImage!,
        filename: 'image.jpg', // Dummy filename
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(imageFileBytes);

      // Debugging: Print request details
      print('Request URL: ${request.url}');
      print('Request Headers: ${request.headers}');
      print('Request Fields: ${request.fields}');
      print('Request Files: ${request.files}');

      // Send request
      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${responseBody.body}');

      if (response.statusCode == 201) {
        final newCategory = json.decode(responseBody.body)['category'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Category created successfully!')),
        );
        Navigator.pop(context); // Go back to the previous screen
      } else {
        print('Failed to create category: ${responseBody.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create category: ${responseBody.body}')),
        );
      }
    } catch (e) {
      print('Error creating category: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating category: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Category',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF5AA5B1),
        elevation: 10,
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600), // Center and constrain for larger screens
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Input Section
                  Text(
                    'Category Title',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5AA5B1),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Enter category title',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Color(0xFF5AA5B1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF5AA5B1), width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Image Picker Section
                  Text(
                    'Category Image',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5AA5B1),
                    ),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: _pickImage,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Color(0xFF5AA5B1), width: 2),
                          boxShadow: [
                            if (_selectedImage != null)
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                          ],
                        ),
                        child: _selectedImage != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.memory(
                            _selectedImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                            : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
                            SizedBox(height: 10),
                            Text(
                              'Tap to choose an image',
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Visibility Toggle Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Visibility',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF5AA5B1),
                        ),
                      ),
                      Transform.scale(
                        scale: 1.3,
                        child: Switch(
                          value: _isVisible,
                          onChanged: (value) {
                            setState(() {
                              _isVisible = value;
                            });
                          },
                          activeColor: Color(0xFF5AA5B1),
                          inactiveTrackColor: Colors.redAccent.withOpacity(0.5),
                          inactiveThumbColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Create Button
                  ElevatedButton.icon(
                    onPressed: _createCategory,
                    icon: Icon(Icons.add, color: Colors.white),
                    label: Text(
                      'Create Category',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF5AA5B1),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      shadowColor: Colors.tealAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


}
