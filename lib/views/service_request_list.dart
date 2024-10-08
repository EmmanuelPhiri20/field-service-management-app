import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fsm_app/model/service_request.dart';
import 'edit_request_screen.dart';

class ServiceRequestList extends StatelessWidget {
  const ServiceRequestList({super.key});

  Future<void> _deleteServiceRequest(BuildContext context, String requestId) async {
    // Show a confirmation dialog before deleting
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Service Request'),
          content: const Text('Are you sure you want to delete this service request?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('service_requests')
            .doc(requestId)
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service request deleted successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete service request: $e')),
        );
      }
    }
  }

  Future<void> _editServiceRequest(BuildContext context, ServiceRequest request) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditRequestScreen(serviceRequest: request),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid; // Get the current user's UID

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade900,
              Colors.purple.shade700,
              Colors.blue.shade600,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title section for Service Requests
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Service Requests',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Title color
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('service_requests')
                    .where('user_id', isEqualTo: userId) // Filter by user ID
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No service requests found.'));
                  }

                  List<ServiceRequest> serviceRequests = snapshot.data!.docs.map((doc) {
                    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                    return ServiceRequest(
                      id: doc.id,
                      category: data['service_type'] ?? '',
                      description: data['description'] ?? '',
                      status: data['status'] ?? 'Pending',
                      date: data['date'] ?? '',
                      time: data['time'] ?? '',
                      imageUrl: data['image_url'] ?? '',
                    );
                  }).toList();

                  return ListView.builder(
                    itemCount: serviceRequests.length,
                    itemBuilder: (context, index) {
                      final request = serviceRequests[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        child: ListTile(
                          leading: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blue, width: 2), // Border around the image
                              borderRadius: BorderRadius.circular(10),
                              image: request.imageUrl.isNotEmpty
                                  ? DecorationImage(
                                image: NetworkImage(request.imageUrl),
                                fit: BoxFit.cover,
                              )
                                  : null,
                            ),
                            child: request.imageUrl.isEmpty
                                ? const Icon(Icons.image_not_supported, size: 60)
                                : null,
                          ),
                          title: Text(
                            request.category,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Description: ${request.description}'),
                              Text('Status: ${request.status}'),
                              Text('Date: ${request.date}'),
                              Text('Time: ${request.time}'),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _editServiceRequest(context, request);
                              } else if (value == 'delete') {
                                _deleteServiceRequest(context, request.id);
                              }
                            },
                            itemBuilder: (BuildContext context) {
                              return [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ];
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
