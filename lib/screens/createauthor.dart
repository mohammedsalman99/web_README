import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

class CreateAuthorPage extends StatefulWidget {
  @override
  _CreateAuthorPageState createState() => _CreateAuthorPageState();
}

class _CreateAuthorPageState extends State<CreateAuthorPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();

  Uint8List? _selectedImage;
  bool _isVisible = true;

  final String _adminToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3MzkzMDZjZDU0OTI2NDI5ODg4MTY0ZCIsImlzQWRtaW4iOnRydWUsImlhdCI6MTczMzM4MzMyMCwiZXhwIjoxNzQxMTU5MzIwfQ.Lzl05Sx4-xm0DCUVPPPAQUtr6A2WB6gk4CXoQd1L8ro';

  Future<void> _pickImage() async {
    final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) async {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(files[0]);

        reader.onLoadEnd.listen((event) {
          setState(() {
            _selectedImage = reader.result as Uint8List;
          });
        });
      }
    });
  }
  Future<void> _createAuthor() async {
    final String name = _nameController.text.trim();
    final String bio = _bioController.text.trim();

    if (name.isEmpty || bio.isEmpty || _selectedImage == null) {
      print("Validation failed: Name, bio, or image is missing.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please provide name, bio, and select an image')),
      );
      return;
    }

    final url = 'https://readme-backend-zdiq.onrender.com/api/v1/authors';
    print("Request URL: $url");

    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));

      request.headers['Authorization'] = 'Bearer $_adminToken';
      print("Authorization Header: ${request.headers['Authorization']}");

      request.fields['fullName'] = name;
      request.fields['bio'] = bio;

      print("Request Fields: ${request.fields}");

      final imageFileBytes = http.MultipartFile.fromBytes(
        'profilePicture',
        _selectedImage!,
        filename: 'profile.jpg',
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(imageFileBytes);
      print("Image file added to request.");

      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${responseBody.body}");

      if (response.statusCode == 201) {
        final newAuthor = json.decode(responseBody.body)['author'];
        print("Author created successfully: $newAuthor");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Author created successfully!')),
        );
        Navigator.pop(context, newAuthor);
      } else {
        print("Failed to create author: ${responseBody.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create author: ${responseBody.body}')),
        );
      }
    } catch (e) {
      print("Error creating author: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating author: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Author',
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
          constraints: BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField('Full Name', _nameController),
                  SizedBox(height: 20),
                  _buildTextField('Bio', _bioController, maxLines: 5),
                  SizedBox(height: 20),
                  Text(
                    'Profile Picture',
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
                  _buildTextField('Facebook URL', _facebookController),
                  SizedBox(height: 10),
                  _buildTextField('Instagram URL', _instagramController),
                  SizedBox(height: 10),
                  _buildTextField('LinkedIn URL', _linkedinController),
                  SizedBox(height: 10),
                  _buildTextField('Website URL', _websiteController),
                  SizedBox(height: 20),
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
                  ElevatedButton.icon(
                    onPressed: _createAuthor,
                    icon: Icon(Icons.add, color: Colors.white),
                    label: Text(
                      'Create Author',
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

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
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
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: 'Enter $label',
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
      ],
    );
  }
}
