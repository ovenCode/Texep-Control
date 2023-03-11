import 'dart:developer';

import 'package:flutter/material.dart';

class Devlog {
  Devlog(String message) {
    log(message);
  }

  Widget toDialog(BuildContext context, String message) {
    return AlertDialog(
      title: const Text("Error"),
      content: Text(message),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Return"))
      ],
    );
  }

  Devlog.toDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
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
