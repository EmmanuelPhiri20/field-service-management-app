import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<int> countServiceRequests() async {
    QuerySnapshot snapshot = await _firestore.collection('service_requests').get();
    return snapshot.docs.length;
  }


  Future<int> countCompletedRequests() async {
    QuerySnapshot snapshot = await _firestore.collection('service_requests')
        .where('status', isEqualTo: 'Completed')
        .get();
    return snapshot.docs.length;
  }
}
