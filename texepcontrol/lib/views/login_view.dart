import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:texepcontrol/logic/api_service.dart';
import 'package:texepcontrol/logic/api_victron.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Logger();
  }
}

class Logger extends StatefulWidget {
  const Logger({super.key});

  @override
  State<Logger> createState() => _LoggerState();
}

class _LoggerState extends State<Logger> {
  final TextEditingController loginController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    // TODO: implement dispose
    loginController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Center(
        child: Column(
          children: [
            Row(
              children: [
                const Text("Login"),
                SizedBox(
                    width: 250,
                    child: TextField(
                      key: const ValueKey("login"),
                      controller: loginController,
                      decoration:
                          const InputDecoration(hintText: "Enter login"),
                      keyboardType: TextInputType.emailAddress,
                    ))
              ],
            ),
            Row(
              children: [
                const Text("Password"),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                  child: SizedBox(
                    width: 250,
                    child: TextField(
                      key: const ValueKey("password"),
                      controller: passwordController,
                      decoration:
                          const InputDecoration(hintText: "Enter password"),
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                    ),
                  ),
                )
              ],
            ),
            TextButton(
                onPressed: () {
                  // TODO: implement onPressed
                  String login = loginController.text,
                      password = passwordController.text;
                  _apiService.addService("Victron");

                  (_apiService.getServices[0] as ApiVictron).setUser = {
                    "username": login.trim(),
                    "password": password.trim()
                  };

                  (_apiService.getServices[0] as ApiVictron).isUserDefined =
                      true;
                  (_apiService.getServices[0] as ApiVictron).connect();

                  log("LoginView::build: answer from LoginView: ${(_apiService.getServices[0] as ApiVictron).getConnectionResponse.toString()}");
                  Navigator.of(context).pop(
                      (_apiService.getServices[0] as ApiVictron)
                          .getConnectionResponse);
                },
                child: const Text("Login")),
          ],
        ),
      ),
    );
  }
}
