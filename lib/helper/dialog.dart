import 'package:flutter/material.dart';

class CustomDialog {
  static void showSnackbar(
    BuildContext context,
    String message, {
    Color backgroundColor = Colors.black,
    Color textColor = Colors.white,
  }) {
    final snackBar = SnackBar(
      content: Center(
        child: Text(
          message,
          style: TextStyle(
            color: textColor, // Use custom text color
          ),
        ),
      ),
      backgroundColor: backgroundColor, // Use custom background
      behavior: SnackBarBehavior.floating,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void showProgressBar(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true, // ✅ ensures it's shown above all
      builder: (_) => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF3AAA35),
        ),
      ),
    );
  }

  static void hideProgressBar(BuildContext context) {
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
}
