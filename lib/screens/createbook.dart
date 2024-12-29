import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

class CreateBookPage extends StatefulWidget {
  @override
  _CreateBookPageState createState() => _CreateBookPageState();
}

class _CreateBookPageState extends State<CreateBookPage> {
  final _formKey = GlobalKey<FormState>();
  final String _adminToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3MzkzMDZjZDU0OTI2NDI5ODg4MTY0ZCIsImlzQWRtaW4iOnRydWUsImlhdCI6MTczMzM4MzMyMCwiZXhwIjoxNzQxMTU5MzIwfQ.Lzl05Sx4-xm0DCUVPPPAQUtr6A2WB6gk4CXoQd1L8ro';

  String title = '';
  Uint8List? _selectedImage;
  String category = '';
  List<String> selectedAuthors = [];
  List<Map> categories = [];
  List<Map> authors = [];
  double price = 0.0;
  bool free = false;
  String bookLink = '';
  String description = '';
  Map? selectedCategory;

  @override
  void initState() {
    super.initState();
    fetchCategories();
    fetchAuthors();
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
    final html.FileUploadInputElement uploadInput = html
        .FileUploadInputElement();
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

  Future<void> _submitBook() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    final url = 'https://readme-backend-zdiq.onrender.com/api/v1/books';

    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['Authorization'] = 'Bearer $_adminToken';
      request.fields['title'] = title;
      request.fields['category'] = selectedCategory?['_id'] ?? '';
      request.fields['authors'] = selectedAuthors.join(',');
      request.fields['free'] = free.toString();
      request.fields['bookLink'] = bookLink;
      request.fields['description'] = description;

      if (!free) {
        request.fields['price'] = price.toString();
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

      if (response.statusCode == 201) {
        print('Book created successfully');
        final newBook = json.decode(responseBody.body)['book'];
        Navigator.pop(context, newBook);
      } else {
        print('Failed to create book: ${response.statusCode}');
        print('Response: ${responseBody.body}');
      }
    } catch (e) {
      print('Error creating book: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Book'),
        centerTitle: true,
        backgroundColor: Color(0xFF5AA5B1),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 800),
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              scrollbars: false, 
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
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
                            _buildTextField('Title', (value) => title = value),
                            SizedBox(height: 20),
                            _buildDropdown(
                              'Category',
                              categories,
                              selectedCategory,
                                  (value) => setState(() => selectedCategory = value),
                            ),
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
                              children: selectedAuthors
                                  .map((authorId) {
                                final author = authors.firstWhere(
                                        (author) => author['_id'] == authorId,
                                    orElse: () => {});
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
                              value: free,
                              onChanged: (value) {
                                setState(() {
                                  free = value;
                                  if (free) price = 0.0;
                                });
                              },
                              activeColor: Color(0xFF5AA5B1),
                            ),
                            if (!free)
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: _buildTextField(
                                  'Price',
                                      (value) => price = double.tryParse(value) ?? 0.0,
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextField(
                              'Book Link',
                                  (value) => bookLink = value,
                              validator: (value) =>
                              value == null || value.isEmpty
                                  ? 'Please enter a book link'
                                  : null,
                            ),
                            SizedBox(height: 20),
                            _buildTextField(
                              'Description',
                                  (value) => description = value,
                              maxLines: 4,
                            ),
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
                              : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.upload_file,
                                  size: 50, color: Colors.grey),
                              SizedBox(height: 8),
                              Text(
                                'Tap to pick an image',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: SizedBox(
                          width: 300,
                          child: ElevatedButton(
                            onPressed: _submitBook,
                            child: Text(
                              'Submit',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              backgroundColor: Color(0xFF5AA5B1),
                              shadowColor: Colors.teal,
                              elevation: 5,
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

  Widget _buildTextField(
      String label,
      Function(String) onSave, {
        String? Function(String?)? validator,
        int maxLines = 1,
        TextInputType keyboardType = TextInputType.text,
      }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 16, color: Colors.black87),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Color(0xFF5AA5B1), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF5AA5B1), width: 2),
        ),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      onSaved: (value) => onSave(value!),
      validator: validator,
    );
  }

  Widget _buildDropdown(
      String label,
      List<Map> items,
      Map? selectedItem,
      Function(Map?) onChanged,
      ) {
    return DropdownButtonFormField<Map>(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 16, color: Colors.black87),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Color(0xFF5AA5B1)),
        ),
      ),
      value: selectedItem,
      items: items
          .map((item) => DropdownMenuItem(
        value: item,
        child: Text(item['title'] ?? item['fullName'] ?? 'Unknown'),
      ))
          .toList(),
      onChanged: onChanged,
    );
  }
}
