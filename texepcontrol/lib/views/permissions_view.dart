import 'package:flutter/material.dart';

/// A view that's only launched only once normally, after the installation of the app
/// to request all necessary permissions from the user. This view might appear also after
/// some unusual reinitializations of the app (like if the user clears the cache)
class PermissionsView extends StatefulWidget {
  const PermissionsView({super.key});

  static const String permissionsRequest =
          "In order to use this application, you need to allow some permissions.",
      termsRequest = "You've read and accepted the Terms of Service.";

  @override
  State<PermissionsView> createState() => _PermissionsViewState();
}

class _PermissionsViewState extends State<PermissionsView> {
  bool termsAccepted = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ADD image here later
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(PermissionsView.permissionsRequest),
            ),
            SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: termsAccepted,
                    onChanged: (value) {
                      setState(() {
                        termsAccepted = value ?? false;
                      });
                    },
                  ),
                  const Text(PermissionsView.termsRequest)
                ],
              ),
            ),
            ElevatedButton(
              onPressed: termsAccepted ? () {} : null,
              child: const Text("Go to Settings"),
            )
          ],
        ),
      ),
    );
  }
}
