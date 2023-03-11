import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import 'api_service.dart';

class ApiVictron extends ApiService {
  static const String victronAPIAdress = "https://vrmapi.victronenergy.com/v2";
  static const String victronAPILoginAdress =
      "https://vrmapi.victronenergy.com/v2/auth/login";
  Map<String, String>? user;
  final Map<String, String> _connectionResponse = {};
  String? _token;

  ApiVictron();

  @override
  Stream<String> connect() async* {
    // TODO: improve connect implementation
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
          yield "Waiting";
        }
      }
      if (connect.request?.finalized ?? false) {
        log(connect.statusCode.toString());
        _token = _connectionResponse["token"];
        log(_connectionResponse.toString());
        yield "Success";
      }
    }
  }

  String? get getToken => _token;

  @override
  void disconnect() async {
    // TODO: implement disconnect
  }

  @override
  set setUser(Map<String, String> val) {
    isUserDefined = true;
    user = val;
  }

  @override
  // TODO: implement getConnectionResponse
  Map<String, String> get getConnectionResponse => _connectionResponse;

  void createToken() async {
    http.Response response = await http.post(
        Uri.parse(
            "https://vrmapi.victronenergy.com/v2/users/${_connectionResponse["idUser"]}/accesstokens/create"),
        body: jsonEncode({"user1": "MyNewToken"}));

    _token = jsonDecode(response.body);
  }

  @override
  Future<void> requestSites() async {
    http.Response response = await http.get(
        Uri.parse(
            "https://vrmapi.victronenergy.com/v2/users/${_connectionResponse["idUser"]}/installations?extended=1"),
        headers: {
          "content-type": "application/json",
          "x-authorisation": "Token $_token",
        });

    if (response.statusCode == 200) {
      // TODO: implement requestSites
      final Map<dynamic, dynamic> mapJson = jsonDecode(response.body);
      log("ApiVictron::requestSites::result: ${mapJson.toString()}");
    } else if (response.statusCode == 403) {
      final Map<dynamic, dynamic> mapJson = jsonDecode(response.body);
      log("ApiVictron::requestSites::result: ${mapJson.toString()}");
    }
  }
}
