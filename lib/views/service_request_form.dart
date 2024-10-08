import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import '../controller/service_request_controller.dart';
import 'service_request_list.dart';
import 'dart:io';
import 'package:intl/intl.dart';


class ServiceRequestForm extends StatefulWidget {
  const ServiceRequestForm({super.key});

  @override
  _ServiceRequestFormState createState() => _ServiceRequestFormState();
}

class _ServiceRequestFormState extends State<ServiceRequestForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _smsController = TextEditingController();
  LatLng? _currentPosition;
  bool _showMap = false;
  bool _isLoading = false; // Track loading state
  bool _isImageLoading = false; // Track image loading state
  String? _selectedServiceType;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  File? _selectedImage; // Store captured image

  final List<String> serviceTypes = [
    'Plumbing',
    'Electricity',
    'Carpentry',
    'Dish/Satellite Installer',
    'Solar System Installer'
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _clientNameController.dispose();
    _smsController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.denied) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _showMap = true;
      _isLoading = false;
    });
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    setState(() {
      _isImageLoading = true;
    });

    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _isImageLoading = false;
      });
    } else {
      setState(() {
        _isImageLoading = false;
      });
    }
  }


  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedServiceType != null) {
      setState(() {
        _isLoading = true;
      });

      try {

        await ServiceRequestController().createServiceRequest(
          serviceType: _selectedServiceType!,
          clientName: _clientNameController.text,
          description: _descriptionController.text ,
          timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
          date: _selectedDate?.toIso8601String(),
          time: _selectedTime?.format(context),
          location: _currentPosition != null
              ? '${_currentPosition!.latitude}, ${_currentPosition!.longitude}'
              : 'Unknown location',
          imageFile: _selectedImage, // Pass the image file for upload
        );


        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ServiceRequestList(),
          ),
        );


        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service request submitted successfully!')),
        );
      } catch (e) {
        // Handle errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit service request: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Service Request'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade900,
              Colors.purple.shade700,
              Colors.blue.shade600,
            ],
          ),
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: _clientNameController,
                        decoration: const InputDecoration(
                          labelText: 'Client Name',
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the client\'s name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      DropdownButtonFormField<String>(
                        value: _selectedServiceType,
                        hint: const Text(
                          'Select Service Type',
                          style: TextStyle(color: Colors.white),
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Service Type',
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                        dropdownColor: Colors.blue.shade600,
                        items: serviceTypes.map((String service) {
                          return DropdownMenuItem<String>(
                            value: service,
                            child: Text(
                              service,
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedServiceType = newValue;
                          });
                        },
                        validator: (value) => value == null ? 'Please select a service type' : null,
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (_selectedDate != null && _selectedTime != null)
                            Text(
                              'Scheduled for ${DateFormat('yyyy-MM-dd').format(_selectedDate!)} at ${_selectedTime!.format(context)}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          if (_selectedDate == null || _selectedTime == null)
                            ElevatedButton(
                              onPressed: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2101),
                                );
                                if (picked != null && picked != _selectedDate) {
                                  setState(() {
                                    _selectedDate = picked;
                                  });
                                }
                                final TimeOfDay? pickedTime = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (pickedTime != null && pickedTime != _selectedTime) {
                                  setState(() {
                                    _selectedTime = pickedTime;
                                  });
                                }
                              },
                              child: const Text(
                                'Schedule Service',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade600,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          const Text(
                            'Capture Image',
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.camera_alt),
                            color: Colors.white,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      if (_isImageLoading)
                        const CircularProgressIndicator(),
                      if (_selectedImage != null && !_isImageLoading)
                        Container(
                          height: 150,
                          width: 150,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue.shade600),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(height: 20),

                      Container(
                        height: 1,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 20),

                      if (_showMap && _currentPosition != null)
                        Container(
                          height: 300,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue.shade600),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Stack(
                            children: [
                              FlutterMap(
                                options: MapOptions(
                                  center: _currentPosition,
                                  zoom: 15.0,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                    subdomains: ['a', 'b', 'c'],
                                  ),
                                  CircleLayer(
                                    circles: [
                                      CircleMarker(
                                        point: _currentPosition!,
                                        color: Colors.red.withOpacity(0.7),
                                        borderStrokeWidth: 2,
                                        borderColor: Colors.lightBlue,
                                        radius: 12,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Positioned(
                                top: 10,
                                left: 10,
                                child: Text(
                                  'Location',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 20),

                      Container(
                        height: 1,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 20),

                      const SizedBox(height: 20),

                      const SizedBox(height: 20),

                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                        onPressed: _submitForm,
                        child: const Text(
                          'Submit Request',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_isLoading) ...[
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}