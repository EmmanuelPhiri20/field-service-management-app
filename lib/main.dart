import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'views/login_screen.dart';
import 'views/registration_screen.dart';
import 'views/themes/theme_provider.dart';
import 'views/dashboard_screen.dart';
import 'views/service_request_form.dart';
import 'views/service_request_list.dart';
import 'views/analytics_screen.dart';
import 'views/profile_screen.dart';
import 'views/settings_screen.dart';
import 'views/sms.dart';
import 'views/edit_request_screen.dart';
import 'model/service_request.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const FSMApp(),
    ),
  );
}

class FSMApp extends StatelessWidget {
  const FSMApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'FSM App',
      theme: themeProvider.currentTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/login': (context) => const LoginScreen(),
        '/RegistrationScreen': (context) => const RegistrationScreen(),
        '/DashboardScreen': (context) => const DashboardScreen(),
        '/ServiceRequestForm': (context) => const ServiceRequestForm(),
        '/ServiceRequestList': (context) => const ServiceRequestList(),
        '/AnalyticsScreen': (context) => const AnalyticsScreen(),
        '/ProfileScreen': (context) => const ProfileScreen(),
        '/SettingsScreen': (context) => const SettingsScreen(),
        '/SMSScreen': (context) => const SMSScreen(),
        '/editRequest': (context) {
          final ServiceRequest request = ModalRoute.of(context)!.settings.arguments as ServiceRequest;
          return EditRequestScreen(serviceRequest: request);
        },
      },
    );
  }
}
