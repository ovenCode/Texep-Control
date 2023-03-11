import 'package:flutter/material.dart';

class BluetoothException implements Exception {
  String errorInfo;

  BluetoothException(this.errorInfo);

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

class ConnectionException implements Exception {
  String errorInfo;
  ConnectionException(this.errorInfo);
  Future<void> showErrorDialog(
      BuildContext context, String errorMessage) async {
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

class ReadingException implements Exception {
  String errorInfo;

  ReadingException(this.errorInfo);

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

class WritingException implements Exception {
  String errorInfo;
  StackTrace stackTrace;

  WritingException(this.errorInfo, this.stackTrace);

  void showErrorDialog(
      BuildContext context, String errorMessage, StackTrace stackTrace) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text("$errorMessage: $stackTrace"),
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
