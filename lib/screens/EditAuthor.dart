import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

class EditAuthorPage extends StatefulWidget {
  final Map author;

  const EditAuthorPage({Key? key, required this.author}) : super(key: key);

  @override
  _EditAuthorPageState createState() => _EditAuthorPageState();
}

class _EditAuthorPageState extends State<EditAuthorPage> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _facebookController;
  late TextEditingController _instagramController;
  late TextEditingController _linkedinController;
  late TextEditingController _websiteController;

  Uint8List? _selectedImage;
  late bool _isVisible;
  String? _existingProfilePicture;

  final String _adminToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3MzkzMDZjZDU0OTI2NDI5ODg4MTY0ZCIsImlzQWRtaW4iOnRydWUsImlhdCI6MTczMzM4MzMyMCwiZXhwIjoxNzQxMTU5MzIwfQ.Lzl05Sx4-xm0DCUVPPPAQUtr6A2WB6gk4CXoQd1L8ro';

  @override
  void initState() {
    super.initState();

    print("Author Data: ${widget.author}");
    _nameController = TextEditingController(text: widget.author['fullName'] ?? '');
    _bioController = TextEditingController(text: widget.author['bio'] ?? '');

    final socialLinks = widget.author['socialLinks'] ?? {};
    print("Social Links: $socialLinks");

    _facebookController = TextEditingController(text: socialLinks['facebook'] ?? '');
    _instagramController = TextEditingController(text: socialLinks['instagram'] ?? '');
    _linkedinController = TextEditingController(text: socialLinks['linkedin'] ?? '');
    _websiteController = TextEditingController(text: socialLinks['website'] ?? '');

    _isVisible = widget.author['isVisible'] ?? true;
    _existingProfilePicture = widget.author['profilePicture'];
  }


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

  Future<void> _editAuthor() async {
    final String name = _nameController.text.trim();
    final String bio = _bioController.text.trim();

    if (name.isEmpty || bio.isEmpty) {
      print("Validation failed: Name or bio is empty.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please provide name and bio')),
      );
      return;
    }

    if (widget.author == null || widget.author['_id'] == null) {
      print("Error: widget.author or widget.author['_id'] is null.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Author data is missing')),
      );
      return;
    }

    final url = 'https://readme-backend-zdiq.onrender.com/api/v1/authors/${widget.author['_id']}';
    print("Request URL: $url");

    try {
      final request = http.MultipartRequest('PUT', Uri.parse(url));

      request.headers['Authorization'] = 'Bearer $_adminToken';
      print("Authorization Header: ${request.headers['Authorization']}");

      request.fields['fullName'] = name;
      request.fields['bio'] = bio;

      print("Request Fields: ${request.fields}");
      if (_selectedImage != null) {
        final imageFileBytes = http.MultipartFile.fromBytes(
          'profilePicture',
          _selectedImage!,
          filename: 'profile.jpg',
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(imageFileBytes);
        print("Image file added to request.");
      }

      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${responseBody.body}");

      if (response.statusCode == 200) {
        final updatedAuthor = json.decode(responseBody.body)['author'];
        print("Author updated successfully: $updatedAuthor");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Author updated successfully!')),
        );
        Navigator.pop(context, updatedAuthor);
      } else {
        print("Failed to update author: ${responseBody.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update author: ${responseBody.body}')),
        );
      }
    } catch (e) {
      print("Error updating author: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating author: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Author',
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
                            if (_selectedImage != null || _existingProfilePicture != null)
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
                            : _existingProfilePicture != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            _existingProfilePicture!,
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
                    onPressed: _editAuthor,
                    icon: Icon(Icons.save, color: Colors.white),
                    label: Text(
                      'Save Changes',
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
