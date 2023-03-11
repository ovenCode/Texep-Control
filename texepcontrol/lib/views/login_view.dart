import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:texepcontrol/constants/colors.dart';
import 'package:texepcontrol/logic/api_services.dart';
import 'package:texepcontrol/logic/api_victron.dart';
import 'package:texepcontrol/logic/bluetooth_exceptions.dart';
import 'package:texepcontrol/utils/devlog.dart';

class LoginView extends StatelessWidget {
  final ApiServices apiServices;
  const LoginView({super.key, required this.apiServices});

  @override
  Widget build(BuildContext context) {
    return Logger(
      apiServices: apiServices,
    );
  }
}

class Logger extends StatefulWidget {
  final ApiServices apiServices;
  const Logger({super.key, required this.apiServices});

  @override
  State<Logger> createState() => _LoggerState();
}

class _LoggerState extends State<Logger> {
  final TextEditingController loginController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  ApiServices _apiService = ApiServices();

  bool dataReceived = false;

  @override
  void initState() {
    _apiService = widget.apiServices;
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    loginController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String>? answer;
    BuildContext back = context;
    if (!dataReceived) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Login"),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Column(
            children: [
              Row(
                children: [
                  const Text("Login"),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                    child: SizedBox(
                        width: 250,
                        child: TextField(
                          key: const ValueKey("login"),
                          controller: loginController,
                          decoration:
                              const InputDecoration(hintText: "Enter login"),
                          keyboardType: TextInputType.emailAddress,
                        )),
                  )
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: () async {
                      // TODO: implement onPressed
                      showDialog(
                          context: context,
                          builder: (context) {
                            // Future.value(() async* {
                            //   String login = loginController.text,
                            //       password = passwordController.text;
                            //   _apiService.addService("Victron");

                            //   (_apiService.getServices[0] as ApiVictron).setUser =
                            //       {
                            //     "username": login.trim(),
                            //     "password": password.trim()
                            //   };

                            //   (_apiService.getServices[0] as ApiVictron)
                            //       .isUserDefined = true;
                            //   await for (String response
                            //       in (_apiService.getServices[0] as ApiVictron)
                            //           .connect()) {}
                            //   Map<String, String> answer =
                            //       (_apiService.getServices[0] as ApiVictron)
                            //           .getConnectionResponse;
                            // });

                            String login = loginController.text,
                                password = passwordController.text;

                            (_apiService.getServices[0]).setUser = {
                              "username": login.trim(),
                              "password": password.trim()
                            };

                            Stream<String> connectionInfo =
                                (_apiService.getServices[0]).connect();

                            return StreamBuilder(
                              stream: connectionInfo,
                              builder: (context, snapshot) {
                                try {
                                  if (snapshot.hasError) {
                                    log("No data to present. ${snapshot.error.toString()}");
                                    return const Text("No data in stream");
                                  } else {
                                    switch (snapshot.connectionState) {
                                      case ConnectionState.waiting:
                                        Devlog("Waiting for data");
                                        log("Attempting to show dialog.");
                                        return const AlertDialog(
                                          title: Text("Attempting to login"),
                                          content: Text("Waiting..."),
                                          actions: [
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 0, 0, 5.0),
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  value: null,
                                                  strokeWidth: 7.0,
                                                  backgroundColor:
                                                      ColorsExt.brown100,
                                                  color: ColorsExt.brown500,
                                                  semanticsLabel: "Waiting...",
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      case ConnectionState.active:
                                        break;
                                      case ConnectionState.done:
                                        Devlog("Data received");
                                        answer = (_apiService.getServices[0]
                                                as ApiVictron)
                                            .getConnectionResponse;
                                        Devlog(
                                            "ConnectionState.done::Answer: ${answer.toString()}");
                                        dataReceived = true;
                                        Navigator.pop(context, answer);

                                        // return AlertDialog(
                                        //   content: Center(
                                        //     child: Column(
                                        //       crossAxisAlignment:
                                        //           CrossAxisAlignment.center,
                                        //       children: [
                                        //         const Text(
                                        //             "Successfully logged in"),
                                        //         ElevatedButton(
                                        //             onPressed: () =>
                                        //                 Navigator.pop(context),
                                        //             child: const Text("Close"))
                                        //       ],
                                        //     ),
                                        //   ),
                                        // );
                                        break;
                                      case ConnectionState.none:
                                        break;
                                      default:
                                        break;
                                    }
                                  }
                                  if (snapshot.hasData) {
                                    if (snapshot.data == "Waiting") {
                                    } else if (snapshot.data == "Success") {
                                      Devlog("Data received");
                                      answer = (_apiService.getServices[0])
                                          .getConnectionResponse;
                                      Devlog(answer.toString());
                                      dataReceived = true;

                                      return AlertDialog(
                                        content: Center(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              const Text(
                                                  "Successfully logged in"),
                                              ElevatedButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text("Close"))
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                    return AlertDialog(
                                      title: const Text("Error"),
                                      content: ElevatedButton(
                                        child: const Text("Close"),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    );
                                  } else {
                                    if (!dataReceived) {
                                      log("Data is not received");
                                      return const Scaffold(
                                          body: Text(
                                              "Idk what happenned, but data is not received"));
                                    } else if (dataReceived) {
                                      log("StreamBuilder: Data is received, popping soon.");
                                      Navigator.pop(context, answer);
                                    }
                                    if (dataReceived) {
                                      Navigator.pop(context, answer);
                                    }
                                    if (dataReceived) {
                                      Navigator.pop(context, answer);
                                    }
                                    return const Scaffold(
                                        body: Text("Idk what happenned"));
                                  }
                                } on ConnectionException catch (errorInfo) {
                                  errorInfo
                                      .showErrorDialog(
                                          context, errorInfo.toString())
                                      .then((value) => null);
                                  return const Scaffold();
                                }
                              },
                            );
                          }).whenComplete(() => Navigator.pop(context, answer));
                      // log("LoginView::build: answer from LoginView: ${answer.toString()}");
                      if (dataReceived) {
                        log("Build: Data is received popping soon");
                        Navigator.pop(back, answer);
                      }
                    },
                    child: const Text("Login")),
              ),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Login"),
        ),
        body: Center(
          child: Column(
            children: [
              const Text("User already logged in"),
              ElevatedButton(
                  onPressed: () => Navigator.pop(context, answer),
                  child: const Text("Close"))
            ],
          ),
        ),
      );
    }
  }
}
