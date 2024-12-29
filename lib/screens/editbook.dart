import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

class EditBookPage extends StatefulWidget {
  final String bookId;

  EditBookPage({required this.bookId});

  @override
  _EditBookPageState createState() => _EditBookPageState();
}

class _EditBookPageState extends State<EditBookPage> {
  final _formKey = GlobalKey<FormState>();
  final String _adminToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3MzkzMDZjZDU0OTI2NDI5ODg4MTY0ZCIsImlzQWRtaW4iOnRydWUsImlhdCI6MTczMzM4MzMyMCwiZXhwIjoxNzQxMTU5MzIwfQ.Lzl05Sx4-xm0DCUVPPPAQUtr6A2WB6gk4CXoQd1L8ro';

  Map<String, dynamic>? bookData;
  Uint8List? _selectedImage;
  List<Map> categories = [];
  List<Map> authors = [];
  List<String> selectedAuthors = [];
  Map? selectedCategory;

  @override
  void initState() {
    super.initState();
    fetchBookDetails();
    fetchCategories();
    fetchAuthors();
  }

  Future<void> fetchBookDetails() async {
    final url = 'https://readme-backend-zdiq.onrender.com/api/v1/books/${widget.bookId}';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $_adminToken'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['book'];
        setState(() {
          bookData = data;
          selectedCategory = data['category'];
          selectedAuthors = List<String>.from(data['authors'].map((a) => a['_id']));
        });
      }
    } catch (e) {
      print('Error fetching book details: $e');
    }
  }

  Future<void> fetchCategories() async {
    final url = 'https://readme-backend-zdiq.onrender.com/api/v1/categories/all';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $_adminToken'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          categories = List<Map>.from(data['categories']);
        });
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  Future<void> fetchAuthors() async {
    final url = 'https://readme-backend-zdiq.onrender.com/api/v1/authors/all';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $_adminToken'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          authors = List<Map>.from(data['authors']);
        });
      }
    } catch (e) {
      print('Error fetching authors: $e');
    }
  }

  Future<void> _pickImage() async {
    final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
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

  Future<void> _updateBook() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    final url = 'https://readme-backend-zdiq.onrender.com/api/v1/books/${widget.bookId}';

    try {
      final request = http.MultipartRequest('PUT', Uri.parse(url));
      request.headers['Authorization'] = 'Bearer $_adminToken';

      request.fields['title'] = bookData!['title'];
      request.fields['category'] = selectedCategory?['_id'] ?? '';
      request.fields['authors'] = selectedAuthors.join(',');
      request.fields['free'] = bookData!['free'].toString();
      request.fields['bookLink'] = bookData!['bookLink'];
      request.fields['description'] = bookData!['description'];

      if (!bookData!['free']) {
        request.fields['price'] = bookData!['price'].toString();
      }

      if (_selectedImage != null) {
        final imageFile = http.MultipartFile.fromBytes(
          'image',
          _selectedImage!,
          filename: 'book_image.jpg',
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(imageFile);
      }

      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        print('Book updated successfully');
        Navigator.pop(context);
      } else {
        print('Failed to update book: ${response.statusCode}');
        print('Response: ${responseBody.body}');
      }
    } catch (e) {
      print('Error updating book: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Book'),
        centerTitle: true,
        backgroundColor: Color(0xFF5AA5B1),
      ),
      body: bookData == null
          ? Center(child: CircularProgressIndicator())
          : Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 800),
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('📘 Book Details'),
                      _buildCard(
                        child: Column(
                          children: [
                            _buildTextField('Title', (value) => bookData!['title'] = value, initialValue: bookData!['title']),
                            SizedBox(height: 20),
                            _buildDropdown('Category', categories, selectedCategory, (value) => setState(() => selectedCategory = value)),
                            SizedBox(height: 20),
                            _buildDropdown(
                              'Authors',
                              authors,
                              null,
                                  (value) {
                                if (!selectedAuthors.contains(value?['_id'])) {
                                  setState(() {
                                    selectedAuthors.add(value?['_id']);
                                  });
                                }
                              },
                            ),
                            SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              children: selectedAuthors.map((authorId) {
                                final author = authors.firstWhere((a) => a['_id'] == authorId, orElse: () => {});
                                return Chip(
                                  label: Text(author['fullName'] ?? 'Unknown'),
                                  backgroundColor: Color(0xFF5AA5B1).withOpacity(0.2),
                                  deleteIcon: Icon(Icons.close, size: 18),
                                  onDeleted: () {
                                    setState(() {
                                      selectedAuthors.remove(authorId);
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildSectionHeader('💵 Pricing and Availability'),
                      _buildCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SwitchListTile(
                              title: Text('Free', style: TextStyle(fontSize: 16)),
                              value: bookData!['free'],
                              onChanged: (value) => setState(() => bookData!['free'] = value),
                              activeColor: Color(0xFF5AA5B1),
                            ),
                            if (!bookData!['free'])
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: _buildTextField(
                                  'Price',
                                      (value) => bookData!['price'] = double.tryParse(value) ?? 0.0,
                                  initialValue: bookData!['price'].toString(),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildSectionHeader('🔗 Book Link and Description'),
                      _buildCard(
                        child: Column(
                          children: [
                            _buildTextField('Book Link', (value) => bookData!['bookLink'] = value, initialValue: bookData!['bookLink']),
                            SizedBox(height: 20),
                            _buildTextField('Description', (value) => bookData!['description'] = value, initialValue: bookData!['description'], maxLines: 4),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildSectionHeader('📷 Upload Image'),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            border: Border.all(color: Color(0xFF5AA5B1), width: 2),
                            borderRadius: BorderRadius.circular(15),
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
                              : bookData!['image'] != null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(
                              bookData!['image'],
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          )
                              : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.upload_file, size: 50, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Tap to pick an image', style: TextStyle(color: Colors.grey, fontSize: 16)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: SizedBox(
                          width: 300,
                          child: ElevatedButton(
                            onPressed: _updateBook,
                            child: Text('Update Book', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              backgroundColor: Color(0xFF5AA5B1),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Icon(Icons.label_important, color: Color(0xFF5AA5B1)),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5AA5B1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }

  Widget _buildTextField(String label, Function(String) onSave, {String? initialValue, int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      initialValue: initialValue,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onSaved: (value) => onSave(value!),
    );
  }

  Widget _buildDropdown(String label, List<Map> items, Map? selectedItem, Function(Map?) onChanged) {
    return DropdownButtonFormField<Map>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      value: categories.isNotEmpty && selectedCategory != null
          ? categories.firstWhere(
            (category) => category['_id'] == selectedCategory?['_id'],
        orElse: () => {}, 
      )
          : null,
      items: categories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category['title'] ?? 'Unknown'),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedCategory = value;
        });
      },
    );
  }


}
