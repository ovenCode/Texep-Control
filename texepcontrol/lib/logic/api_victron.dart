import 'dart:convert';
import 'dart:developer';

import 'package:texepcontrol/logic/api_service.dart';
import 'package:http/http.dart' as http;

class ApiVictron extends ApiService {
  static const String victronAPIAdress = "https://vrmapi.victronenergy.com/v2";
  static const String victronAPILoginAdress =
      "https://vrmapi.victronenergy.com/v2/auth/login";
  Map<String, String>? user;
  final Map<String, String> _connectionResponse = {};
  String? _token;
  bool isUserDefined = false;

  ApiVictron();

  @override
  void connect() async {
    // TODO: implement connect
    if (isUserDefined) {
      int count = 0;
      String buffer = "";
      var connect = await http.post(Uri.parse(victronAPILoginAdress),
          body: jsonEncode(user),
          headers: {"content-type": "application/json"});
      log(user.toString());
      log(connect.body);
      for (String value in connect.body
          .replaceAll("{", "")
          .replaceAll("}", "")
          .replaceAll("\"", "")
          .split(",")) {
        for (String key in value.split(":")) {
          if (count % 2 != 0) {
            _connectionResponse[buffer] = key;
          }
          buffer = key;
          count++;
        }
      }
      log(connect.statusCode.toString());
      _token = _connectionResponse["token"];
      log(_connectionResponse.toString());
    }
  }

  String? get getToken => _token;

  @override
  void disconnect() async {
    // TODO: implement disconnect
  }

  set setUser(Map<String, String> val) => user = val;

  @override
  // TODO: implement getConnectionResponse
  Map<String, String> get getConnectionResponse => _connectionResponse;
}
