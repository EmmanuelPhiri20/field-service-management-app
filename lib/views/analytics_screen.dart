import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  Stream<Map<String, dynamic>> getAnalyticsData() {
    return FirebaseFirestore.instance.collection('service_requests').snapshots().map((snapshot) {
      int totalRequests = snapshot.docs.length;
      int completedRequests = snapshot.docs
          .where((doc) => doc['status'] == 'Completed')
          .length;
      int pendingRequests = snapshot.docs
          .where((doc) => doc['status'] == 'Pending')
          .length;

      return {
        'total': totalRequests,
        'completed': completedRequests,
        'pending': pendingRequests,
      };
    });
  }


  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              'Service Analytics',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            StreamBuilder<Map<String, dynamic>>(
              stream: getAnalyticsData(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }



                final data = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Requests: ${data['total']}', style: const TextStyle(fontSize: 18, color: Colors.white)),
                    Text('Completed: ${data['completed']}', style: const TextStyle(fontSize: 18, color: Colors.green)),
                    Text('Pending: ${data['pending']}', style: const TextStyle(fontSize: 18, color: Colors.red)),
                    const SizedBox(height: 20),
                    const Text('Service Requests Bar Chart', style: TextStyle(fontSize: 18, color: Colors.white)),
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          barGroups: [
                            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: data['completed'].toDouble(), color: Colors.green, width: 20)]),
                            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: data['pending'].toDouble(), color: Colors.red, width: 20)]),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
