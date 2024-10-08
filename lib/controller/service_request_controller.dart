import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ServiceRequestController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance

  // Create a new service request in Firestore
  Future<void> createServiceRequest({
    required String serviceType,
    required String clientName,
    required String description,
    String? timestamp, // Optional timestamp parameter
    String? date,
    String? time,
    String? location,
    File? imageFile,
  }) async {
    try {
      // Get the currently authenticated user's UID
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user');
      }
      final String userId = user.uid;

      // Upload image if provided
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _uploadImageToStorage(imageFile);
      }

      // Add service request to Firestore collection 'service_requests'
      await _firestore.collection('service_requests').add({
        'service_type': serviceType,
        'client_name': clientName,
        'description': description,
        'status': 'Pending', // Set default status as 'Pending'
        'timestamp': timestamp != null
            ? Timestamp.fromMillisecondsSinceEpoch(int.parse(timestamp))
            : Timestamp.now(), // Use provided timestamp or current timestamp
        'date': date,
        'time': time,
        'location': location,
        'image_url': imageUrl, // Store the image URL if the image was uploaded
        'user_id': userId, // Add the authenticated user's ID to associate with this request
      });
      debugPrint('Service request created successfully');
    } catch (e) {
      debugPrint('Failed to submit service request: $e');
      throw e;
    }
  }


  Future<String> _uploadImageToStorage(File imageFile) async {
    try {
      // Define the storage reference for the image
      final storageRef = _storage
          .ref()
          .child('service_request_images/${imageFile.path.split('/').last}');


      final uploadTask = storageRef.putFile(imageFile);

      // Wait for the upload to complete
      final taskSnapshot = await uploadTask;


      final imageUrl = await taskSnapshot.ref.getDownloadURL();

      return imageUrl;
    } catch (e) {
      debugPrint('Failed to upload image: $e');
      throw e;
    }
  }

  // Stream for retrieving user-specific service requests from Firestore
  Stream<QuerySnapshot> getServiceRequests() {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user');
    }
    final String userId = user.uid;

    // Filter service requests to only those created by the logged-in user
    return _firestore
        .collection('service_requests')
        .where('user_id', isEqualTo: userId)
        .snapshots();
  }


  Future<void> updateServiceRequest(String requestId, Map<String, dynamic> data) async {
    try {
      // Update service request document in Firestore by document ID
      await _firestore.collection('service_requests').doc(requestId).update(data);
      debugPrint('Service request updated successfully');
    } catch (e) {
      debugPrint('Failed to update service request: $e');
      throw e;
    }
  }

  // Delete a service request by ID
  Future<void> deleteServiceRequest(String requestId) async {
    try {

      await _firestore.collection('service_requests').doc(requestId).delete();
      debugPrint('Service request deleted successfully');
    } catch (e) {
      debugPrint('Failed to delete service request: $e');
      throw e;
    }
  }
}
