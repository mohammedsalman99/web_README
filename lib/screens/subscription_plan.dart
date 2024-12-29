import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SubscriptionPlanPage extends StatefulWidget {
  @override
  _SubscriptionPlanPageState createState() => _SubscriptionPlanPageState();
}

class _SubscriptionPlanPageState extends State<SubscriptionPlanPage> {
  List plans = [];
  bool isLoading = true;

  final String _token =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3MzkzMDZjZDU0OTI2NDI5ODg4MTY0ZCIsImlzQWRtaW4iOnRydWUsImlhdCI6MTczMzM4MzMyMCwiZXhwIjoxNzQxMTU5MzIwfQ.Lzl05Sx4-xm0DCUVPPPAQUtr6A2WB6gk4CXoQd1L8ro';

  @override
  void initState() {
    super.initState();
    fetchPlans();
  }

  Future<void> fetchPlans() async {
    const String url = 'https://readme-backend-zdiq.onrender.com/api/v1/subscription-plans';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          plans = data['plans'];
          isLoading = false;
        });
      } else {
        print('Failed to load plans: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching plans: $e');
    }
  }

  Future<void> addPlan(String name, double price, int duration) async {
    const String url = 'https://readme-backend-zdiq.onrender.com/api/v1/subscription-plans';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'planName': name,
          'price': price,
          'durationInDays': duration,
        }),
      );

      if (response.statusCode == 201) {
        // Extract the newly created plan from the response
        final Map<String, dynamic> responseData = json.decode(response.body);
        final Map<String, dynamic> newPlan = responseData['plan'];

        // Add the new plan to the list and refresh UI
        setState(() {
          plans.add(newPlan);
        });

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Plan "${newPlan['planName']}" added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Log the status code and response body for debugging
        print('Failed to add plan: ${response.statusCode}, ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add plan. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Catch and log any exceptions
      print('Error adding plan: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while adding the plan.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> editPlan(String id, String name, double price,
      int duration) async {
    final String url = 'https://readme-backend-zdiq.onrender.com/api/v1/subscription-plans/$id';

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'planName': name,
          'price': price,
          'durationInDays': duration,
        }),
      );

      if (response.statusCode == 200) {
        // Parse the updated plan from the response
        final Map<String, dynamic> responseData = json.decode(response.body);
        final Map<String, dynamic> updatedPlan = responseData['plan'];

        // Update the plan in the list
        setState(() {
          final index = plans.indexWhere((plan) => plan['_id'] == id);
          if (index != -1) {
            plans[index] = updatedPlan;
          }
        });

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Plan "${updatedPlan['planName']}" updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Handle server errors and duplicate key error specifically
        final Map<String, dynamic> errorResponse = json.decode(response.body);
        final String errorMessage = errorResponse['error'] ??
            'Unknown error occurred';

        print('Failed to edit plan: ${response.statusCode}, ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage.contains('duplicate key error')
                ? 'The plan name "$name" is already in use. Please choose a different name.'
                : 'Failed to update the plan. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Catch and log any exceptions
      print('Error editing plan: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while updating the plan.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool isDuplicatePlanName(String name) {
    return plans.any((plan) => plan['planName'] == name);
  }

  void _showEditPlanDialog(Map plan) {
    final nameController = TextEditingController(text: plan['planName']);
    final priceController = TextEditingController(
        text: plan['price'].toString());
    final durationController = TextEditingController(
        text: plan['durationInDays'].toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Subscription Plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Plan Name'),
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: durationController,
                decoration: InputDecoration(labelText: 'Duration (days)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final String newName = nameController.text;
                if (isDuplicatePlanName(newName) &&
                    newName != plan['planName']) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'The plan name "$newName" is already in use.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                editPlan(
                  plan['_id'],
                  newName,
                  double.tryParse(priceController.text) ?? 0.0,
                  int.tryParse(durationController.text) ?? 0,
                );
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }


  Future<void> deletePlan(String id) async {
    final String url = 'https://readme-backend-zdiq.onrender.com/api/v1/subscription-plans/$id';

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Parse the response message
        final Map<String, dynamic> responseData = json.decode(response.body);
        final String message = responseData['message'] ??
            'Plan deleted successfully!';

        // Update the state to remove the deleted plan
        setState(() {
          plans.removeWhere((plan) => plan['_id'] == id);
        });

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Log the failure and show an error message
        print(
            'Failed to delete plan: ${response.statusCode}, ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete the plan. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Catch and log any exceptions
      print('Error deleting plan: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while deleting the plan.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  void _showAddPlanDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final durationController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Subscription Plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Plan Name'),
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: durationController,
                decoration: InputDecoration(labelText: 'Duration (days)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                addPlan(
                  nameController.text,
                  double.parse(priceController.text),
                  int.parse(durationController.text),
                );
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB2EBF2)),
        ),
      )
          : plans.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No Subscription Plans Available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: plans.length,
          itemBuilder: (context, index) {
            final plan = plans[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE0F7FA), Color(0xFFB2EBF2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        plan['planName'],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[700],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Price: \$${plan['price']}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Duration: ${plan['durationInDays']} days',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _showEditPlanDialog(plan),
                            icon: Icon(Icons.edit, size: 16, color: Colors.white),
                            label: Text(
                              'Edit',
                              style: TextStyle(color: Colors.white), // Set text color to white
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () => deletePlan(plan['_id']),
                            icon: Icon(Icons.delete, size: 16, color: Colors.white),
                            label: Text(
                              'Delete',
                              style: TextStyle(color: Colors.white), // Set text color to white
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPlanDialog,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Plan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color:Colors.white),
        ),
        backgroundColor: Color(0xFF5AA5B1),
        elevation: 8,
      ),
    );
  }


}
