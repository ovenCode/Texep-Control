import 'package:flutter/material.dart';

class ScanException implements Exception {
  String errorInfo;

  ScanException(this.errorInfo);
  void showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(errorMessage),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Return"))
          ],
        );
      },
    );
  }
}

class ConnectionException implements Exception {}
