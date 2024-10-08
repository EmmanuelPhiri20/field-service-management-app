import 'package:flutter/material.dart';

class NavController {
  void navigateTo(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  void navigateBack(BuildContext context) {
    Navigator.pop(context);
  }

  void navigateToAndReplace(BuildContext context, String routeName) {
    Navigator.pushReplacementNamed(context, routeName);
  }
}
