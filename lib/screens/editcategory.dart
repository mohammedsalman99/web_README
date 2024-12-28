import 'dart:typed_data';
import 'dart:html' as html; 
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

class EditCategoryPage extends StatefulWidget {
  final Map category; 

  const EditCategoryPage({required this.category});

  @override
  _EditCategoryPageState createState() => _EditCategoryPageState();
}

class _EditCategoryPageState extends State<EditCategoryPage> {
  late TextEditingController _titleController;
  late bool _isVisible;
  Uint8List? _selectedImageBytes; 
  String? _selectedImageName;
  final html.FileUploadInputElement _uploadInput = html.FileUploadInputElement();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.category['title']);
    _isVisible = widget.category['isVisible'] ?? true; 
  }

  void _pickImageWeb() async {
    _uploadInput.accept = 'image/*';
    _uploadInput.click();

    _uploadInput.onChange.listen((event) async {
      final file = _uploadInput.files!.first;
      final reader = html.FileReader();

      reader.readAsArrayBuffer(file);

      reader.onLoadEnd.listen((_) {
        setState(() {
          _selectedImageBytes = reader.result as Uint8List;
          _selectedImageName = file.name;
        });
      });
    });
  }

  Future<void> _updateCategory() async {
    final String categoryId = widget.category['_id'];
    final String url = 'https://readme-backend-zdiq.onrender.com/api/v1/categories/$categoryId';
    final token =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3MzkzMDZjZDU0OTI2NDI5ODg4MTY0ZCIsImlzQWRtaW4iOnRydWUsImlhdCI6MTczMzM4MzMyMCwiZXhwIjoxNzQxMTU5MzIwfQ.Lzl05Sx4-xm0DCUVPPPAQUtr6A2WB6gk4CXoQd1L8ro';

    try {
      final request = http.MultipartRequest('PUT', Uri.parse(url));
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['title'] = _titleController.text;
      request.fields['isVisible'] = _isVisible.toString();

      if (_selectedImageBytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          _selectedImageBytes!,
          filename: _selectedImageName,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${responseBody.body}');

      if (response.statusCode == 200) {
        final updatedCategory = json.decode(responseBody.body)['category'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Category updated successfully')),
        );
        Navigator.pop(context, updatedCategory); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update category: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error updating category: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating category: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Category',
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
                  Text(
                    'Category Title',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5AA5B1),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
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
                  SizedBox(height: 20),

                  Text(
                    'Category Image',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5AA5B1),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Color(0xFF5AA5B1), width: 2),
                          ),
                          child: _selectedImageBytes != null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.memory(
                              _selectedImageBytes!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          )
                              : widget.category['image'] != null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(
                              widget.category['image'],
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          )
                              : Center(
                            child: Icon(
                              Icons.image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 20),

                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: _pickImageWeb,
                          child: Container(
                            height: 45,
                            decoration: BoxDecoration(
                              color: Color(0xFF5AA5B1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.upload_file,
                                size: 25,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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

                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: LinearGradient(
                        colors: [Color(0xFF4CA1AF), Color(0xFFC4E0E5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF4CA1AF).withOpacity(0.5),
                          blurRadius: 15,
                          offset: Offset(0, 5),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _updateCategory,
                      icon: Icon(Icons.update, color: Colors.white),
                      label: Text(
                        'Update Category',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        backgroundColor: Colors.transparent, 
                        elevation: 0, 
                      ),
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
