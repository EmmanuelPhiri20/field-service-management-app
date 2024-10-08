import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'service_request_list.dart';
import 'service_request_form.dart';
import 'analytics_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'sms.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  String? userRole;
  bool isLoading = true;

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _getUserRole();
  }

  Future<void> _getUserRole() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUser.uid).get();

        setState(() {
          userRole = userDoc['role'];
          isLoading = false;
          _setupScreensBasedOnRole();
        });
      }
    } catch (e) {
      print("Error fetching user role: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Set up the available screens based on the user's role
  void _setupScreensBasedOnRole() {
    if (userRole == 'Admin') {
      _screens = [
        const DashboardTab(),      // Dashboard summary
        const ServiceRequestList(), // List of service requests
        SMSScreen(),                // SMS screen
        AnalyticsScreen(),          // Analytics tab
        const ProfileScreen(),      // Profile screen
        const SettingsScreen(),     // Settings screen (Admin access)
      ];
    } else if (userRole == 'Technician') {
      _screens = [
        const DashboardTab(),      // Dashboard summary (restricted to Technician)
        const ServiceRequestList(), // Service requests (Technician access)
        SMSScreen(),                // SMS screen
        const ProfileScreen(),      // Profile screen
      ];
    } else if (userRole == 'Manager') {
      _screens = [
        const DashboardTab(),      // Dashboard summary
        const ServiceRequestList(), // Service requests
        SMSScreen(),                // SMS screen
        AnalyticsScreen(),          // Analytics (Manager access)
        const ProfileScreen(),      // Profile screen
        const SettingsScreen(),     // Settings screen (Manager access)
      ];
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading spinner while role is being fetched
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Build the dashboard UI
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade900, // Adjust to match login/register
      ),
      body: AnimatedContainer(
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
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
        child: _screens[_selectedIndex], // Display the screen based on tab selection
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueAccent.shade700, // Color for the selected tab
        unselectedItemColor: Colors.blueGrey,          // Color for unselected tabs
        items: _buildBottomNavBarItems(),
        backgroundColor: Colors.white, // Ensure the background is visible
        showSelectedLabels: true,      // Show labels of selected items
        showUnselectedLabels: true,    // Show labels of unselected items
      ),
    );
  }

  // Dynamically build the BottomNavigationBar items based on the user's role
  List<BottomNavigationBarItem> _buildBottomNavBarItems() {
    if (userRole == 'Admin') {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'Service Requests',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.sms),
          label: 'SMS',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'Analytics',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ];
    } else if (userRole == 'Technician') {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'Service Requests',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.sms),
          label: 'SMS',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    } else if (userRole == 'Manager') {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'Service Requests',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.sms),
          label: 'SMS',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'Analytics',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ];
    }
    return [];
  }
}

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Assigned Service Requests',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 3,
                  child: ListTile(
                    leading: const Icon(Icons.work, color: Colors.blue),
                    title: Text(
                      'Service Request ${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: const Text(
                      'Status: In Progress',
                      style: TextStyle(color: Colors.grey),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blue),
                    onTap: () {

                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {

              Navigator.pushNamed(context, '/ServiceRequestForm');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade900, // Adjust to match login/register
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              'Start New Service Request',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


Map<String, Widget Function(BuildContext)> routes = {
  '/': (context) => const DashboardScreen(),
  '/ServiceRequestForm': (context) => const ServiceRequestForm(),
  // Add other routes as needed
};
