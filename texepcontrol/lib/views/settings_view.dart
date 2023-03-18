import 'package:flutter/material.dart';

/// View showing all available settings
///
/// Here the user will be able to change settings, logout,
/// change the password, etc.
class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Scrollable(
        viewportBuilder: (context, position) {
          return ListView(
            children: [
              Column(
                children: [
                  const Center(child: Text("App")),
                  Row(
                    children: [
                      const Text("Setting 1"),
                      ElevatedButton(
                          onPressed: () {}, child: const Text("value 1")),
                      ElevatedButton(
                          onPressed: () {}, child: const Text("value 2"))
                    ],
                  ),
                  Row(
                    children: [
                      const Text("Setting 2"),
                      ElevatedButton(
                          onPressed: () {}, child: const Text("value 1")),
                      ElevatedButton(
                          onPressed: () {}, child: const Text("value 2"))
                    ],
                  )
                ],
              ),
              Column(
                children: [
                  const Center(child: Text("User")),
                  Row(
                    children: [
                      const Text("Setting 1"),
                      ElevatedButton(
                          onPressed: () {}, child: const Text("value 1")),
                      ElevatedButton(
                          onPressed: () {}, child: const Text("value 2"))
                    ],
                  ),
                  Row(
                    children: [
                      const Text("Setting 2"),
                      ElevatedButton(
                          onPressed: () {}, child: const Text("value 1")),
                      ElevatedButton(
                          onPressed: () {}, child: const Text("value 2"))
                    ],
                  )
                ],
              ),
              Column(
                children: [
                  const Center(child: Text("Miscellaneous")),
                  Row(
                    children: [
                      const Text("Setting 1"),
                      ElevatedButton(
                          onPressed: () {}, child: const Text("value 1")),
                      ElevatedButton(
                          onPressed: () {}, child: const Text("value 2"))
                    ],
                  ),
                  Row(
                    children: [
                      const Text("Setting 2"),
                      ElevatedButton(
                          onPressed: () {}, child: const Text("value 1")),
                      ElevatedButton(
                          onPressed: () {}, child: const Text("value 2"))
                    ],
                  )
                ],
              ),
              Center(
                child: ElevatedButton(
                  child: const Text("Change permissions"),
                  onPressed: () {},
                ),
              ),
              Center(
                child: ElevatedButton(
                  child: const Text("Log out"),
                  onPressed: () {},
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
