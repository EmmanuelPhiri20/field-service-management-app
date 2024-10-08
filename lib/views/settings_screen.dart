import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:fsm_app/views/login_screen.dart';
import 'package:fsm_app/views/themes/theme_provider.dart';
import 'package:form_field_validator/form_field_validator.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);


  Future<void> _changeUsername(BuildContext context) async {
    TextEditingController newUsernameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Username'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: newUsernameController,
                decoration: const InputDecoration(hintText: 'Enter new username'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(hintText: 'Enter password'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String newUsername = newUsernameController.text.trim();
                String password = passwordController.text.trim();

                if (newUsername.isNotEmpty && password.isNotEmpty) {
                  try {
                    // Get current user
                    User? user = FirebaseAuth.instance.currentUser;

                    if (user != null) {
                      // Re-authenticate user using email and password
                      AuthCredential credential = EmailAuthProvider.credential(
                        email: user.email!,
                        password: password,
                      );
                      await user.reauthenticateWithCredential(credential);

                      // Update Firestore with new username
                      DocumentReference userDoc = FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid);
                      await userDoc.update({'username': newUsername});

                      // Update Firebase Authentication with new username
                      await user.updateProfile(displayName: newUsername);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Username changed successfully')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
              child: const Text('Change'),
            ),
          ],
        );
      },
    );
  }

  // Function to change password (with old and new password)
  Future<void> _changePassword(BuildContext context) async {
    TextEditingController oldPasswordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                decoration: const InputDecoration(hintText: 'Enter old password'),
                obscureText: true,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(hintText: 'Enter new password'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String oldPassword = oldPasswordController.text.trim();
                String newPassword = newPasswordController.text.trim();

                if (oldPassword.isNotEmpty && newPassword.isNotEmpty) {
                  try {
                    // Re-authenticate the user with the old password
                    User? user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      AuthCredential credential = EmailAuthProvider.credential(
                        email: user.email!,
                        password: oldPassword,
                      );
                      await user.reauthenticateWithCredential(credential);

                      // To Update password
                      await user.updatePassword(newPassword);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Password changed successfully')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
              child: const Text('Change'),
            ),
          ],
        );
      },
    );
  }

  // Function to log out
  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }


  void _manageServiceCategories(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Default Service Categories'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                CheckboxListTile(
                  title: Text("Electrical Services"),
                  value: true, // Placeholder, you will handle this dynamically
                  onChanged: null,
                ),
                CheckboxListTile(
                  title: Text("Plumbing"),
                  value: true, // Placeholder
                  onChanged: null,
                ),
                CheckboxListTile(
                  title: Text("HVAC"),
                  value: false, // Placeholder
                  onChanged: null,
                ),
                CheckboxListTile(
                  title: Text("Cleaning Services"),
                  value: true, // Placeholder
                  onChanged: null,
                ),
                CheckboxListTile(
                  title: Text("IT Support"),
                  value: false, // Placeholder
                  onChanged: null,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );

  }

  // Function to manage notification settings
  void _manageNotificationSettings(BuildContext context) {

  }

  // Function to manage language preferences
  void _manageLanguagePreferences(BuildContext context) {

  }

  // Function to manage user profiles and permissions
  void _manageUserProfiles(BuildContext context) {

  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Change Username'),
            onTap: () {
              _changeUsername(context); // Function to change username
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            onTap: () {
              _changePassword(context); // Function to change password
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (bool value) {
                themeProvider.toggleTheme();
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Default Service Categories'),
            onTap: () {
              _manageServiceCategories(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notification Settings'),
            onTap: () {
              _manageNotificationSettings(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language Preferences'),
            onTap: () {
              _manageLanguagePreferences(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.admin_panel_settings),
            title: const Text('Manage User Profiles & Permissions'),
            onTap: () {
              _manageUserProfiles(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text ('Delete Account'),
            onTap: () {
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              _logout(context);
            },
          ),
        ],
      ),
    );
  }
}
