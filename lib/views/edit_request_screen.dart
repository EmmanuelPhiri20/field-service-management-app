import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fsm_app/model/service_request.dart';

class EditRequestScreen extends StatefulWidget {
  final ServiceRequest serviceRequest;

  const EditRequestScreen({super.key, required this.serviceRequest});

  @override
  _EditRequestScreenState createState() => _EditRequestScreenState();
}

class _EditRequestScreenState extends State<EditRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _category;
  late String _description;
  late String _status;
  late String _date;
  late String _time;
  bool _isLoading = false;

  // Predefined list of service categories
  final List<String> _serviceTypes = [
    'Plumbing',
    'Electricity',
    'Carpentry',
    'Dish/Satellite Installer',
    'Solar System Installer'
  ];

  @override
  void initState() {
    super.initState();
    _category = widget.serviceRequest.category; // Initialize category from the service request
    _description = widget.serviceRequest.description;
    _status = widget.serviceRequest.status;
    _date = widget.serviceRequest.date;
    _time = widget.serviceRequest.time;
  }

  // Function to pick time using TimePicker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()), // Default to current time
    );

    if (picked != null) {
      setState(() {
        _time = picked.format(context);
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;  // Start showing the loader
      });

      try {
        await FirebaseFirestore.instance
            .collection('service_requests')
            .doc(widget.serviceRequest.id)
            .update({
          'service_type': _category,
          'description': _description,
          'status': _status,
          'date': _date,
          'time': _time,
        });

        // Show SnackBar upon success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Changes saved successfully!')),
        );

        Navigator.pop(context);
      } catch (e) {
        // Handle errors (optional)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save changes: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Service Request'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Container(
        height: double.infinity, // Make the container full screen
        width: double.infinity, // Make the container full screen
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade900,
              Colors.purple.shade700,
              Colors.blue.shade600,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _category,
                    decoration: const InputDecoration(
                      labelText: 'Service Type',
                      labelStyle: TextStyle(color: Colors.white), // Change label text color to white
                    ),
                    items: _serviceTypes.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category, style: const TextStyle(color: Colors.white)), // Change text color to white
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _category = value!; // Update category
                      });
                    },
                    validator: (value) =>
                    value == null ? 'Please select a service type' : null,
                    dropdownColor: Colors.blue.shade900, // Change dropdown color to blue
                  ),
                  TextFormField(
                    initialValue: _description,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      labelStyle: TextStyle(color: Colors.white), // Change label text color to white
                    ),
                    style: const TextStyle(color: Colors.white), // Change text color to white
                    onChanged: (value) => _description = value,
                    validator: (value) =>
                    value!.isEmpty ? 'Please enter a description' : null,
                  ),
                  TextFormField(
                    initialValue: _status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      labelStyle: TextStyle(color: Colors.white), // Change label text color to white
                    ),
                    style: const TextStyle(color: Colors.white), // Change text color to white
                    onChanged: (value) => _status = value,
                    validator: (value) =>
                    value!.isEmpty ? 'Please enter a status' : null,
                    enabled: _status != 'Pending', // Disable if status is 'Pending'
                  ),
                  TextFormField(
                    initialValue: _date,
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      labelStyle: TextStyle(color: Colors.white), // Change label text color to white
                    ),
                    style: const TextStyle(color: Colors.white), // Change text color to white
                    onChanged: (value) => _date = value,
                  ),
                  TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Time',
                      labelStyle: const TextStyle(color: Colors.white), // Change label text color to white
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.access_time),
                        onPressed: () => _selectTime(context), // Open time picker
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    controller: TextEditingController(text: _time),
                  ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade900, // Change button color to dark blue
                    ),
                    child: const Text('Save Changes', style: TextStyle(color: Colors.white)), // Change button text color to white
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