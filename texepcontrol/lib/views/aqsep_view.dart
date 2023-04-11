import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';

class AqSepView extends StatefulWidget {
  const AqSepView({super.key});

  @override
  State<AqSepView> createState() => _AqSepViewState();
}

class _AqSepViewState extends State<AqSepView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AqSep Controls")),
      body: Column(
        children: [
          Center(
            child: ElevatedButton(
              child: const Text("Get status"),
              onPressed: () async {
                //
              },
            ),
          )
        ],
      ),
    );
  }
}

void _sendSMS() {}
