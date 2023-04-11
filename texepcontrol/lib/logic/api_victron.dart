import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:texepcontrol/constants/codes/victron/codes_responses.dart';
import 'package:texepcontrol/logic/bluetooth_exceptions.dart';

import 'api_service.dart';

class ApiVictron extends ApiService {
  static const String victronAPIAdress = "https://vrmapi.victronenergy.com/v2";
  static const String victronAPILoginAdress =
      "https://vrmapi.victronenergy.com/v2/auth/login";
  Map<String, String>? user;
  final Map<String, String> _connectionResponse = {};
  final http.Client _client = http.Client();
  http.Response? _connect;
  String? _token;
  final Map<String, String> _sites = {}, _deviceNames = {}, _deviceStats = {};
  final Map<String, _ApiVictronResponse> _responses = {};

  ApiVictron();

  @override
  Stream<String> connect() async* {
    // TODO: improve connect implementation
    if (isUserDefined) {
      int count = 0;
      String buffer = "";

      log("ApiVictron::connect: User is defined, attempting connection");
      user?["remember_me"] = "true";
      _connect = await _client.post(Uri.parse(victronAPILoginAdress),
          body: jsonEncode(user),
          headers: {"content-type": "application/json"});
      log(user.toString());
      log(_connect!.body);
      for (String value in _connect!.body
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
      if (_connect!.request?.finalized ?? false) {
        log(_connect!.body.toString());
        log(_connect!.statusCode.toString());
        _token = _connectionResponse["token"];
        log(_connectionResponse.toString());
        yield "Success";
      }
    }
  }

  String? get getToken => _token;

  @override
  Future<String> disconnect() async {
    // TODO: implement disconnect
    try {
      http.Response response = await _client.get(
          Uri.tryParse("https://vrmapi.victronenergy.com/v2/auth/logout") ??
              Uri(),
          headers: {"x-authorization": "Bearer $_token"});
      if (response.statusCode == 200) {
        return "Success";
      }
      return "No answer";
    } catch (e) {
      log("ApiVictron::disconnect: Error: ${e.toString()}");
      throw UnimplementedError();
    }
  }

  @override
  set setUser(Map<String, String> val) {
    isUserDefined = true;
    user = val;
  }

  @override
  Map<String, String> get getConnectionResponse => _connectionResponse;

  void createToken() async {
    http.Response response = await _client.post(
        Uri.parse(
            "https://vrmapi.victronenergy.com/v2/users/${_connectionResponse["idUser"]}/accesstokens/create"),
        body: {
          "user1": "MyNewToken"
        },
        headers: {
          "x-authorization":
              "Token 778a2aef91b2c3419b36786377e9710bdc1d70eef7006526bb79a55e114aa9c3"
        });

    _token = jsonDecode(response.body);
  }

  @override
  Future<String> requestSites() async {
    log("ApiVictron::requestSites: Attempting to get info from: https://vrmapi.victronenergy.com/v2/users/${_connectionResponse["idUser"]}/installations?extended=1");

    try {
      http.Response response = await _client.get(
          Uri.parse(
              "https://vrmapi.victronenergy.com/v2/users/${_connectionResponse["idUser"]}/installations"),
          headers: {
            "x-authorization": "Bearer $_token",
          });

      if (response.statusCode == 200) {
        final Map<dynamic, dynamic> mapJson = jsonDecode(response.body);
        log("ApiVictron::requestSites::result: ${mapJson.toString()}");
        for (var value in mapJson.entries) {
          if (value.key == "records") {
            for (int i = 0; i < (value.value as List<dynamic>).length; i++) {
              for (var entry
                  in (value.value[i] as Map<dynamic, dynamic>).entries) {
                if (entry.key == "idSite") {
                  _sites["idSite"] = entry.value.toString();
                }
                if (entry.key == "name") {
                  _sites["name"] = entry.value;
                }
              }
            }
          }
        }
        log("ApiVictron::requestSites: String of sites ${_sites.toString()}");
        return "Success";
      } else {
        final Map<dynamic, dynamic> mapJson = jsonDecode(response.body);
        log("ApiVictron::requestSites::result: ${mapJson.toString()} | Status Code: ${response.statusCode}");
        throw ConnectionException(mapJson.toString());
      }
    } on ConnectionException catch (e) {
      log("ApiVictron::requestSites::ConnectionException: Error: ${e.errorInfo}");
      return "Instance of ConnectionException";
    } catch (e) {
      log("Something happened in requestSites ${e.toString()}");
      throw "Error requesting sites";
    }
  }

  @override
  Map<String, String> get getSites => _sites;

  /// Request Victron Site Devices
  ///
  /// This function gets the devices installed at [siteId]
  ///
  ///
  /// Response examples
  /// 200
  ///
  /// {
  ///   "success": true,
  ///   "records": {
  ///    "devices": [
  ///   {
  ///     "name": "string",
  ///   "customName": null,
  ///   "productCode": "string",
  ///   "productName": "string",
  ///   "idSite": 0,
  ///   "firmwareVersion": "string",
  ///   "lastConnection": "string",
  ///   "class": "string",
  ///   "connection": "string",
  ///   "instance": 0,
  ///   "idDeviceType": 0,
  ///   "settings": [
  ///    {
  ///     "description": "string",
  ///     "enumData": [
  ///      {
  ///        "nameEnum": "string",
  ///         "valueEnum": 0,
  ///        "values": {
  ///           "property1": 0,
  ///            "property2": 0
  ///         }
  ///        }
  ///      ],
  ///     "idDataAttribute": "string",
  ///     "idDeviceType": "string",
  ///     "idSite": "string",
  ///     "idUser": null,
  ///     "loggedTimestamp": "string",
  ///     "loggedValue": 0,
  ///     "timestamp": null,
  ///     "user_name": null,
  ///     "value": null,
  ///     "attributes": [
  ///       0
  ///    ],
  ///      "values": {
  ///       "property1": {
  ///         "loggedValue": "string",
  ///          "value": "string"
  ///        },
  ///      "property2": {
  ///        "loggedValue": "string",
  ///        "value": "string"
  ///      }
  ///     }
  ///      }
  ///     ],
  ///     "signalRSSI": "string",
  ///     "signalSNR": "string",
  ///     "signalFrequency": "string",
  ///     "antennaType": "Internal",
  ///     "networkName": "string",
  ///     "loggingInterval": 0,
  ///     "identifier": "string",
  ///     "lastPowerUpOrRestart": "string",
  ///     "machineSerialNumber": null,
  ///     "remoteOnLan": "string",
  ///     "autoUpdate": "On",
  ///     "updateTo": "Official release",
  ///     "vncSshAuth": true,
  ///     "vncStatus": "Enabled",
  ///     "vncPort": 0,
  ///     "twoWayCommunication": true,
  ///     "remoteSupportEnabled": true,
  ///     "remoteSupportPort": 0,
  ///     "remoteSupportIp": "string",
  ///     "remoteSupport": "enabled_online",
  ///     "productId": "string",
  ///     "vmc": "string",
  ///     "vid": {
  ///     "enumValue": "Single unit",
  ///     "devicesPerPhase": {
  ///         "L1": 0,
  ///         "L2": 0,
  ///         "L3": 0
  ///         }
  ///       },
  ///       "tempSensorConnected": true,
  ///       "froniusDeviceType": "string",
  ///       "pL": "string",
  ///       "pdV": "string",
  ///       "inputType": "string",
  ///       "inputState": "string"
  ///       }
  ///       ],
  ///       "unconfigured_devices": true
  ///      }
  ///    }
  ///
  /// 4xx
  ///
  ///
  ///
  @override
  Future<String> requestSiteDevices(String siteId) async {
    log("ApiVictron::requestSiteDevices: Trying to get site devices");
    log("link: https://vrmapi.victronenergy.com/v2/installations/${_sites["idSite"]}/system-overview");
    log("SiteID: ");
    log(_sites["idSite"].toString());
    try {
      http.Response response = await _client.get(
          Uri.parse(
              "https://vrmapi.victronenergy.com/v2/installations/${_sites["idSite"]}/system-overview"),
          headers: {
            "x-authorization": "Bearer $_token",
          });
      if (response.statusCode == 200) {
        final Map<String, dynamic> mapJson = jsonDecode(response.body);
        _ApiVictronResponse responseVictron =
            _ApiVictronResponse("List of connected devices", mapJson);
        log("ApiVictron::requestSiteDevices::result: ${mapJson.toString()}");
        for (int i = 0;
            i < responseVictron.records!.victronDevices!.length;
            i++) {
          _deviceNames["productName$i"] =
              responseVictron.records!.victronDevices![i].productName ?? "";
        }

        log("ApiVictron::requestSiteDevices: String of devices ${_deviceNames.toString()}");
        //log("ApiVictron::requestSiteDevices: Responses ${responseVictron._responses.toString()}");
        //log("ApiVictron::requestSiteDevices: Records ${responseVictron.records.toString()}");
        //log("ApiVictron::requestSiteDevices: Devices ${responseVictron.records?.victronDevices.toString()}");
        return "Success";
      } else {
        log("ApiVictron::requestSiteDevices: Error ${response.statusCode} ${response.body.toString()}");
      }
    } catch (e) {
      return e.toString();
    }

    return "Some freaking error";
  }

  @override
  Map<String, String> get getDeviceNames => _deviceNames;

  @override
  Future<String> requestSiteStats(String siteId) async {
    log("ApiVictron::requestSiteStats: Trying to get site devices");
    log("link: https://vrmapi.victronenergy.com/v2/installations/${_sites["idSite"]}/stats");
    log("SiteID: ");
    log(_sites["idSite"].toString());
    try {
      http.Response response = await _client.get(
          Uri.parse(
              "https://vrmapi.victronenergy.com/v2/installations/${_sites["idSite"]}/stats"),
          headers: {
            "x-authorization": "Bearer $_token",
          });
      if (response.statusCode == 200) {
        final Map<String, dynamic> mapJson = jsonDecode(response.body);
        _ApiVictronResponse responseVictron =
            _ApiVictronResponse("Installation stats", mapJson);
        log("ApiVictron::requestSiteStats::result: ${mapJson.toString()}");
        for (var value in mapJson.entries) {
          if (value.key == "records") {
            // for (int i = 0;
            //     i < (value.value as Map<dynamic, dynamic>).entries.length;
            //     i++) {
            //   _deviceStats[(value.value as Map<dynamic, dynamic>)
            //           .keys
            //           .elementAt(i)] =
            //       (value.value as Map<dynamic, dynamic>).values.elementAt(i);
            // }

            for (var record in value.value.entries) {
              _deviceStats[record.key.toString()] = record.value.toString();
            }
          }
        }
        log("ApiVictron::requestSiteStats: String of devices ${_deviceStats.toString()}");
        //log("ApiVictron::requestSiteStats: This is the object responseVictron: ${responseVictron.toString()}");
        //log("RESPONSES: ${responseVictron.getResponses.toString()}");
        //log("RECORDS: ${responseVictron.records.toString()}");
        return "Success";
      } else {
        log("ApiVictron::requestSiteStats: Error ${response.statusCode} ${response.body.toString()}");
      }
    } catch (e) {
      throw e.toString();
    }

    return "Some freaking error";
  }

  @override
  Map<String, String> get getDeviceStats => _deviceStats;

  @override
  Future<String> requestData(String datatype) async {
    //final Map<String, dynamic> mapJson = {};
    log("ApiVictron::requestData: Trying to request $datatype data.");
    switch (datatype) {
      case "Diagnostic data":
        try {
          //
          log("Entered TRY: Requesting diagnostic data");
          await requestDiagnosticData();
          return "Success";
        } catch (e) {
          return "ApiVictron::requestData::Diagnostic data: Error requesting data: ${e.toString()}";
        }
      case "Solar Charger summary":
        try {
          //
          log("Entered TRY: Requesting Solar Charger Summary");
          await requestSolarChargerSummary();
          return "Success";
        } catch (e) {
          return "ApiVictron::requestData: Error requesting data: ${e.toString()}";
        }
      case "Installation data":
        try {
          log("ApiVictron::requestData: Requesting Installation Data synchronously");
          requestInstallationData();
          return "Success";
        } catch (e) {
          log(e.toString());
          return "ApiVictron::requestData: Error requesting data: ${e.toString()}";
        }
      case "System Overview summary":
        try {
          await getSystemOverviewSummary();
          return "Success";
        } catch (e) {
          return "ApiVictron::requestData: Error requesting data: ${e.toString()}";
        }
      default:
        return "Error unknown";
    }
  }

  @override
  Stream<String> readData(String datatype) async* {
    log("ApiVictron::readData: Trying to read $datatype data.");
    switch (datatype) {
      case "Solar Charger summary":
        try {
          //
          log("Entered TRY: Requesting Solar Charger Summary");
          await for (final val in requestSolarChargerSummaryStream()) {
            if (val.statusCode == 200) {
              //
              log("Request is successful. Parsing data.");
              _responses["Solar Charger summary"] = _ApiVictronResponse(
                  "Solar Charger summary", jsonDecode(val.body));
              //log("ApiVictron::readData: This is the object responseVictron: ${_responses["Solar Charger summary"]?.toString()}");
              //log("ApiVictron::readData::Solar Charger Summary: This is the records object in responseVictron: ${_responses["Solar Charger summary"]?.records?.data?.properties?["81"].toString()}");
              if (_responses["Solar Charger summary"]!
                      .records!
                      .properties
                      ?.isNotEmpty ??
                  false) {
                // for (var property
                //     in _responses["Solar Charger summary"]!.records!.properties!) {
                //   log(property);
                // }
              }
              yield "Success";
            } else {
              _responses["Solar Charger summary data"] = _ApiVictronResponse(
                  "Solar Charger summary", jsonDecode(val.body));
              log("ApiVictron::requestSolarChargerSummary::Status code: ${val.statusCode}");
              log("ApiVictron::requestSolarChargerSummary: Error info: ${_responses["Solar Charger summary data"]?.errors.toString()}");
              yield "Error";
            }
          }
        } catch (e) {
          yield "ApiVictron::requestData: Error requesting data: ${e.toString()}";
        }
        break;
      case "System Overview summary":
        try {
          getSystemOverviewSummary().asStream().forEach((element) async {
            return;
          }).then((value) async* {
            yield "Success";
          });
        } catch (e) {
          yield "ApiVictron::requestData: Error requesting data: ${e.toString()}";
        }
        break;
      default:
        yield "Error unknown";
    }
  }

  /// Function requesting the diagnostic data for the entire installation site
  Future<void> requestDiagnosticData() async {
    try {
      http.Response response = await _client.get(
          Uri.parse(
              "https://vrmapi.victronenergy.com/v2/installations/${_sites["idSite"]}/diagnostics?count=600"),
          headers: {"x-authorization": "Bearer $_token"});
      if (response.statusCode == 200) {
        //
        log("Diagnostic data: Request is successful. Parsing data.");
        _responses["Diagnostic data"] = _ApiVictronResponse.fromList(
            "Diagnostic data", jsonDecode(response.body));
        // if (_responses["Diagnostic data"]?.records?.properties != null) {
        //   for (var element
        //       in _responses["Diagnostic data"]!.records!.properties!) {
        //     log("${element.code}/${element.idDataAttribute} - ${element.description}");
        //   }
        // }
        //log("ApiVictron::requestData::Diagnostic data: This is the body: ${response.body.toString()}");
        //log("ApiVictron::requestData::Diagnostic data: Test: ${_responses["Diagnostic data"]?.records?.data?.properties?["442"] ?? "can't read responseVictron records"}");
        //log("ApiVictron::requestData: This is the records object in responseVictron: ${_responses["Diagnostic data"].toString()}");
      } else {
        log("ApiVictron::requestDiagnosticData::Status code: ${response.statusCode}");
      }
    } catch (e) {
      log("ApiVictron::requestData::Diagnostic data::Error: ${e.toString()}");
    }
  }

  /// Function getting system overview summary
  ///
  /// More detailed information about it will be added later
  Future<void> getSystemOverviewSummary() async {
    try {
      http.Response response = await _client.get(
          Uri.parse(
              "https://vrmapi.victronenergy.com/v2/installations/${_sites["idSite"]}/widgets/Status"),
          headers: {"x-authorization": "Bearer $_token"});
      if (response.statusCode == 200) {
        //
        log("System Overview summary: Request is successful. Parsing data.");
        _responses["System Overview summary"] = _ApiVictronResponse(
            "System Overview summary", jsonDecode(response.body));

        //log("ApiVictron::getSystemOverviewSummary: This is the body: ${response.body.toString()}");
        //log("ApiVictron::getSystemOverviewSummary: Test: ${_responses["System Overview summary"]?.records?.data?.properties?["40"] ?? "can't read responseVictron records"}");
        //log("ApiVictron::requestData: This is the records object in responseVictron: ${_responses["System Overview summary"].toString()}");
        //_responses["System Overview summary"] = responseVictron;
      } else {
        log("ApiVictron::getSystemOverviewSummary::Status code: ${response.statusCode}");
      }
    } catch (e) {
      log("ApiVictron::requestData::System Overview summary::Error: ${e.toString()}");
    }
  }

  /// Function getting SolarCharger data
  ///
  /// not sure yet about return type, but it will get the http
  /// response from Victron API
  Future<void> requestSolarChargerSummary() async {
    // TODO: implement requestSolarChargerSummary()
    try {
      http.Response response = await _client.get(
          Uri.parse(
              "https://vrmapi.victronenergy.com/v2/installations/${_sites["idSite"]}/widgets/SolarChargerSummary"),
          headers: {"x-authorization": "Bearer $_token"});
      if (response.statusCode == 200) {
        //
        log("Request is successful. Parsing data.");
        _responses["Solar Charger summary"] = _ApiVictronResponse(
            "Solar Charger summary", jsonDecode(response.body));
        log("ApiVictron::requestData: This is the object responseVictron: ${_responses["Solar Charger summary"]?.toString()}");
        log("ApiVictron::requestData::Solar Charger Summary: This is the records object in responseVictron: ${_responses["Solar Charger summary"]?.records?.data?.properties?["81"].toString()}");
        if (_responses["Solar Charger summary"]!
                .records!
                .properties
                ?.isNotEmpty ??
            false) {
          for (var property
              in _responses["Solar Charger summary"]!.records!.properties!) {
            log(property);
          }
        }
      } else {
        _responses["Solar Charger summary data"] = _ApiVictronResponse(
            "Solar Charger summary", jsonDecode(response.body));
        log("ApiVictron::requestSolarChargerSummary::Status code: ${response.statusCode}");
        log("ApiVictron::requestSolarChargerSummary: Error info: ${_responses["Solar Charger summary data"]?.errors.toString()}");
      }
    } catch (e) {
      log("ApiVictron::requestSolarChargerSummary: Error ${e.toString()}");
    }
  }

  Stream<http.Response> requestSolarChargerSummaryStream() async* {
    yield* Stream.periodic(const Duration(seconds: 2), (value) async {
      try {
        http.Response response = await _client.get(
            Uri.parse(
                "https://vrmapi.victronenergy.com/v2/installations/${_sites["idSite"]}/widgets/SolarChargerSummary"),
            headers: {"x-authorization": "Bearer $_token"});
        return response;
      } catch (e) {
        log("ApiVictron::requestSolarChargerSummaryStream: Error ${e.toString()}");
        throw Exception();
      }
    }).asyncMap((event) async => await event);
  }

  Future<void> requestInstallationData() async {
    try {
      http.Response response = await _client.get(
          Uri.parse(
              "https://vrmapi.victronenergy.com/v2/installations/${_sites["idSite"]}/data-download"),
          headers: {"x-authorization": "Bearer $_token"});
      if (response.statusCode == 200) {
        //
        log("Installation data: Request is successful. Parsing data.");
        _ApiVictronResponse responseVictron =
            _ApiVictronResponse.fromCSV("Installation data", response.body);

        log("ApiVictron::requestData: This is the body: ${response.body.toString()}");

        log("ApiVictron::requestData: This is the records object in responseVictron: ${responseVictron.toString()}");
      } else {
        log("ApiVictron::requestInstallationData::Status code: ${response.statusCode}");
      }
    } catch (e) {
      log("ApiVictron::requestInstallationData::Error: ${e.toString()}");
    }
  }

  @override
  dynamic getResponse(String request) {
    switch (request) {
      case "Input Voltage Phase 1":
        return _responses["System Overview summary"]
                ?.records
                ?.data
                ?.properties?["8"]
                .toStringOf("value") ??
            "No response";
      case "Output Voltage Phase 1":
        return _responses["System Overview summary"]
                ?.records
                ?.data
                ?.properties?["20"]
                .toStringOf("value") ??
            "No response";
      case "Battery Voltage":
        return _responses["System Overview summary"]
                ?.records
                ?.data
                ?.properties?["32"]
                .toStringOf("value") ??
            "No response";
      case "Battery Current":
        return _responses["System Overview summary"]
                ?.records
                ?.data
                ?.properties?["33"]
                .toStringOf("value") ??
            "No response";
      case "VE.Bus State":
        return _responses["System Overview summary"]
                ?.records
                ?.data
                ?.properties?["40"]
                .toStringOf("value") ??
            "No response";
      case "Solar Charger Voltage":
        return _responses["Solar Charger summary"]
                ?.records
                ?.data
                ?.properties?["81"]
                .toStringOf("value") ??
            "No response";

      case "Diagnostic data":
        try {
          Map<String, dynamic> data = <String, dynamic>{};
          if (_responses["Diagnostic data"]?.records?.properties?.isNotEmpty ??
              false) {
            for (var element
                in _responses["Diagnostic data"]!.records!.properties!) {
              data["${element.instance} ${element.code}"] = element.map();
            }

            return data;
          }
        } catch (e) {
          log("ApiVictron::requestData::Diagnostic data: Error reading/mapping responses: ${e.toString()}");
        }
        break;
      case "Diagnostic data codes":
        try {
          return _responses["Diagnostic data"]
              ?.records
              ?.properties
              ?.map((e) => {
                    "code": e?.code ?? "no code",
                    "idAttribute": e?.idDataAttribute ?? "no attribute",
                    "description": e?.description ?? "no description"
                  })
              .toList();
        } catch (e) {
          log("ApiVictron::requestData::Diagnostic data: Error reading/mapping responses: ${e.toString()}");
          break;
        }
      default:
        return _responses[request].toString();
    }
  }

  void closeClient() {
    _client.close();
  }
}

/// Responses from the Victron Api
///
///
class _ApiVictronResponse {
  bool? success;
  _VictronResponseRecords? records;
  int? numRecords;
  String? errorCode;
  dynamic errors, totals;

  final Map<String, dynamic> _responses = {};
  _ApiVictronResponse(String type, Map<String, dynamic> json) {
    success = json["success"];
    if (success == true) {
      records = _VictronResponseRecords(type, json["records"]);
      numRecords = json["num_records"];
      if (records != null) {
        _setResponse(VRMAPI_CONNECTED_DEVICES, records!);
      } else if (json["totals"] != null) {
        totals = json["totals"];
      }
    } else {
      success = json["success"];
      errors = json["errors"];
      errorCode = json["error_code"];
    }
  }

  _ApiVictronResponse.fromCSV(String type, dynamic csv) {}

  _ApiVictronResponse.fromList(String type, Map<String, dynamic> json) {
    success = json["success"];
    if (success == true) {
      records = _VictronResponseRecords.fromList(type, json["records"]);
    } else {
      // TODO: to check if error is working
      success = json["success"];
      errors = json["errors"];
      errorCode = json["error_code"];
    }
  }
  // _ApiVictronResponse.isSuccessful(
  //     {required this.success, required this.records});

  // _ApiVictronResponse.isUnsuccessful(
  //     {required this.success, required this.errors, required this.errorCode});

  void _setResponse(int code, _VictronResponseRecords records) {
    switch (code) {
      case VRMAPI_CONNECTED_DEVICES:
        _responses["connected_devices"] = records;
        break;
      default:
    }
  }

  Map<String, dynamic> get getResponses => _responses;

  @override
  String toString() {
    String answer = "";

    answer = records.toString();

    return super.toString();
  }
}

/// Records part of a response body
class _VictronResponseRecords {
  List<_VictronDevice>? victronDevices;
  _VictronUnconfiguredDevices?
      victronUnconfiguredDevices; // causes error, no error with List<_VictronUnconfiguredDevice>?
  _VictronData? data;
  _VictronMeta? meta;
  List<int>? attributeOrder;
  String? token;
  List<dynamic>? properties;
  dynamic property;

  _VictronResponseRecords(String type, dynamic records) {
    if (type == "List of connected devices") {
      victronDevices = List<_VictronDevice>.from(
          records["devices"].map((x) => (_VictronDevice.fromJson(x))));
      victronUnconfiguredDevices = _VictronUnconfiguredDevices.fromValue(
          records["unconfigured_devices"]);
    } else if (type == "Login to Victron") {
      // TODO: implement response for connect()
    } else if (type == "Diagnostic data") {
      try {
        properties = List.generate(
            records.length,
            (index) => _VictronDataProperty(
                code: records[index]["code"].toString(),
                dataAttributeName: records[index]["dataAttributeName"],
                dataType: records[index]["dataType"],
                dbusPath: records[index]["dbusPath"],
                dbusServiceType: records[index]["dbusServiceType"],
                description: records[index]["description"],
                formatValueOnly: records[index]["formatValueOnly"].toString(),
                formatWithUnit: records[index]["formatWithUnit"].toString(),
                formattedValue: records[index]["formattedValue"].toString(),
                hasOldData: records[index]["hasOldData"],
                idDataAttribute: records[index]["idDataAttribute"].toString(),
                instance: records[index]["instance"],
                isKeyDataAttribute: records[index]["isKeyDataAttribute"],
                isValid: records[index]["isValid"],
                nameEnum: records[index]["nameEnum"],
                rawValue: records[index]["rawValue"].toString(),
                secondsAgo: records[index]["secondsAgo"],
                secondsToNextLog: records[index]["secondsToNextLog"],
                value: records[index]["value"],
                valueEnum: records[index]["valueEnum"],
                valueFloat: records[index]["valueFloat"],
                valueFormattedValueOnly: records[index]
                    ["valueFormattedValueOnly"],
                valueFormattedWithUnit: records[index]
                    ["valueFormattedWithUnit"],
                valueString: records[index]["valueString"],
                dataAttributeEnum: records[index]["dataAttributeEnum"]?.map(
                    (x) => _VictronDataAttributeEnum(
                        nameEnum: x["nameEnum"], valueEnum: x["valueEnum"]))));
      } catch (e) {
        log("VictronResponseRecords::Solar Charger summary::Error assigning data: ${e.toString()}");
      }
    } else if (type == "Installation stats") {
      if (records is List<dynamic>) {
        properties = records;
      } else {
        property = records;
      }
    } else if (type == "Solar Charger summary") {
      //
      try {
        data = _VictronData.fromJson(records["data"]);
        meta = _VictronMeta.fromJson(records["meta"]);
        attributeOrder = records["attrubuteOrder"];
      } catch (e) {
        log("VictronResponseRecords::Solar Charger summary::Error assigning data: ${e.toString()}");
      }
    } else if (type == "Installation data") {
      // TODO: implement for installation data
    } else if (type == "System Overview summary") {
      try {
        data = _VictronData.fromJson(records["data"]);
        meta = _VictronMeta.fromJson(records["meta"]);
        attributeOrder = records["attrubuteOrder"];
      } catch (e) {
        log("VictronResponseRecords::System Overview summary::Error assigning data: ${e.toString()}");
      }
    }
  }

  _VictronResponseRecords.fromList(String type, dynamic objects) {
    if (type == "Diagnostic data") {
      try {
        properties = List.generate(
            objects.length,
            (index) => _VictronDataProperty(
                code: objects[index]["code"].toString(),
                dataAttributeName: objects[index]["dataAttributeName"],
                dataType: objects[index]["dataType"],
                dbusPath: objects[index]["dbusPath"],
                dbusServiceType: objects[index]["dbusServiceType"],
                description: objects[index]["description"],
                formatValueOnly: objects[index]["formatValueOnly"].toString(),
                formatWithUnit: objects[index]["formatWithUnit"].toString(),
                formattedValue: objects[index]["formattedValue"].toString(),
                hasOldData: objects[index]["hasOldData"],
                idDataAttribute: objects[index]["idDataAttribute"].toString(),
                instance: objects[index]["instance"],
                isKeyDataAttribute: objects[index]["isKeyDataAttribute"],
                isValid: objects[index]["isValid"],
                nameEnum: objects[index]["nameEnum"],
                rawValue: objects[index]["rawValue"].toString(),
                secondsAgo: objects[index]["secondsAgo"],
                secondsToNextLog: objects[index]["secondsToNextLog"],
                value: objects[index]["value"],
                valueEnum: objects[index]["valueEnum"],
                valueFloat: objects[index]["valueFloat"],
                valueFormattedValueOnly: objects[index]
                    ["valueFormattedValueOnly"],
                valueFormattedWithUnit: objects[index]
                    ["valueFormattedWithUnit"],
                valueString: objects[index]["valueString"],
                dataAttributeEnum: objects[index]["dataAttributeEnum"]?.map(
                    (x) => _VictronDataAttributeEnum(
                        nameEnum: x["nameEnum"], valueEnum: x["valueEnum"]))));
      } catch (e) {
        log("VictronResponseRecords::Diagnostic data::Error assigning data: ${e.toString()}");
      }
    }
  }

  @override
  String toString() {
    // TODO: implement toString
    String answer = "";
    if (properties?.isNotEmpty ?? false) {
      for (var prop in properties!) {
        answer += prop?.toString() ?? "";
      }
    }

    return super.toString();
  }
}

///
///
/// Enum with all the names of the fields readable from the Victron API
enum VictronResponseRecordsKeys {
  code,
  dataAttributeName,
  dataType,
  dbusPath,
  dbusServiceType,
  description,
  formatValueOnly,
  formatWithUnit,
  formattedValue,
  hasOldData,
  idDataAttribute,
  instance,
  isKeyDataAttribute,
  isValid,
  nameEnum,
  rawValue,
  secondsAgo,
  secondsToNextLog,
  value,
  valueEnum,
  valueFloat,
  valueFormattedValueOnly,
  valueFormattedWithUnit,
  valueString,
  dataAttributeEnum
}

abstract class _VictronEnum {}

class _VictronData {
  _VDSecondsAgo? secondsAgo;
  bool? hasOldData;
  Map<String, dynamic>? properties;

  _VictronData(
      {required this.secondsAgo, required this.hasOldData, this.properties});

  factory _VictronData.fromJson(Map<String, dynamic> json) {
    Map<String, _VictronDataProperty> result = {};

    for (var key in json.keys) {
      if (key != "secondsAgo" && key != "hasOldData") {
        result[key.toString()] =
            _VictronDataProperty.fromJson(json[key.toString()]);
      }
    }

    return _VictronData(
        secondsAgo: _VDSecondsAgo.fromJson(json["secondsAgo"]),
        hasOldData: json["hasOldData"],
        properties: result);
  }
}

class _VictronDataProperty {
  String? code,
      dataAttributeName,
      dataType,
      dbusPath,
      dbusServiceType,
      description,
      formatValueOnly,
      formatWithUnit,
      formattedValue,
      idDataAttribute,
      isKeyDataAttribute,
      isValid,
      rawValue,
      secondsAgo,
      secondsToNextLog,
      value,
      valueFormattedValueOnly,
      valueFormattedWithUnit,
      valueString;
  bool? hasOldData;
  int? instance;
  List<_VictronDataAttributeEnum>? dataAttributeEnum;
  dynamic nameEnum, valueEnum, valueFloat;
  _VictronDataProperty(
      {this.code,
      this.dataAttributeName,
      this.dataType,
      this.dbusPath,
      this.dbusServiceType,
      this.description,
      this.formatValueOnly,
      this.formatWithUnit,
      this.formattedValue,
      this.hasOldData,
      this.idDataAttribute,
      this.instance,
      this.isKeyDataAttribute,
      this.isValid,
      this.nameEnum,
      this.rawValue,
      this.secondsAgo,
      this.secondsToNextLog,
      this.value,
      this.valueEnum,
      this.valueFloat,
      this.valueFormattedValueOnly,
      this.valueFormattedWithUnit,
      this.valueString,
      this.dataAttributeEnum});

  factory _VictronDataProperty.fromJson(Map<String, dynamic> json) {
    return _VictronDataProperty(
        code: json["code"],
        dataAttributeName: json["dataAttributeName"],
        dataType: json["dataType"],
        dbusPath: json["dbusPath"],
        dbusServiceType: json["dbusServiceType"],
        description: json["description"],
        formatValueOnly: json["formatValueOnly"],
        formatWithUnit: json["formatWithUnit"],
        formattedValue: json["formattedValue"],
        hasOldData: json["hasOldData"],
        idDataAttribute: json["idDataAttribute"],
        instance: json["instance"],
        isKeyDataAttribute: json["isKeyDataAttribute"],
        isValid: json["isValid"],
        nameEnum: json["nameEnum"],
        rawValue: json["rawValue"],
        secondsAgo: json["secondsAgo"],
        secondsToNextLog: json["secondsToNextLog"],
        value: json["value"],
        valueEnum: json["valueEnum"],
        valueFloat: json["valueFloat"],
        valueFormattedValueOnly: json["valueFormattedValueOnly"],
        valueFormattedWithUnit: json["valueFormattedWithUnit"],
        valueString: json["valueString"],
        dataAttributeEnum: json["dataAttributeEnum"]
            ?.map((x) => _VictronDataAttributeEnum.fromJson(x)));
  }

  @override
  String toString() {
    // TODO: implement toString
    return "_VictronDataProperty:\ncode: $code\ndataAttributeName: $dataAttributeName\ndataType: $dataType\ndbusPath: $dbusPath\ndbusServiceType: $dbusServiceType\nvalue: $value";
  }

  String toStringOf(String val) {
    try {
      switch (val) {
        case "value":
          return value.toString();

        default:
          return "$val doesn't exist in _VictronDataProperty";
      }
    } catch (e) {
      log("toStringOf: $val doesn't exist");
      throw e.toString();
    }
  }

  Map<String, dynamic> map() {
    return {
      "code": code,
      "dataAttributeName": dataAttributeName,
      "dataType": dataType,
      "dbusPath": dbusPath,
      "dbusServiceType": dbusServiceType,
      "description": description,
      "formatValueOnly": formatValueOnly,
      "formatWithUnit": formatWithUnit,
      "formattedValue": formattedValue,
      "hasOldData": hasOldData,
      "idDataAttribute": idDataAttribute,
      "instance": instance,
      "isKeyDataAttribute": isKeyDataAttribute,
      "isValid": isValid,
      "nameEnum": nameEnum,
      "rawValue": rawValue,
      "secondsAgo": secondsAgo,
      "secondsToNextLog": secondsToNextLog,
      "value": value,
      "valueEnum": valueEnum,
      "valueFloat": valueFloat,
      "valueFormattedWithUnit": valueFormattedWithUnit,
      "valueString": valueString,
      "dataAttributeEnum": dataAttributeEnum
    };
  }
}

class _VictronDataAttributeEnum extends _VictronEnum {
  String? nameEnum;
  int? valueEnum;
  _VictronDataAttributeEnum({this.nameEnum, this.valueEnum});

  factory _VictronDataAttributeEnum.fromJson(Map<String, dynamic> json) {
    return _VictronDataAttributeEnum(
        nameEnum: json["nameEnum"], valueEnum: json["valueEnum"]);
  }
}

class _VictronDevice {
  String? name,
      productCode,
      productName,
      firmwareVersion,
      classDevice,
      signalRSSI,
      signalSNR,
      signalFrequency,
      antennaType,
      networkName,
      identifier,
      remoteOnLan,
      autoUpdate,
      updateTo,
      vncStatus,
      remoteSupportIp,
      remoteSupport,
      froniusDeviceType,
      pdV,
      inputState;
  String? customName, connection, machineSerialNumber;
  int? idSite, instance, idDeviceType, vncPort;
  bool? vncSshAuth,
      twoWayCommunication,
      remoteSupportEnabled,
      tempSensorConnected;
  _VictronVID? vid;
  dynamic lastConnection,
      loggingInterval,
      lastPowerUpOrRestart,
      remoteSupportPort,
      productId,
      vmc,
      pL,
      inputType;
  List<_VictronDeviceSettings>? settings;

  _VictronDevice(
      {required this.name,
      this.customName,
      required this.productCode,
      required this.productName,
      required this.idSite,
      required this.firmwareVersion,
      required this.lastConnection,
      required this.classDevice,
      required this.connection,
      required this.instance,
      required this.idDeviceType,
      required this.settings,
      required this.signalRSSI,
      required this.signalSNR,
      required this.signalFrequency,
      required this.antennaType,
      required this.networkName,
      required this.loggingInterval,
      required this.identifier,
      required this.lastPowerUpOrRestart,
      required this.machineSerialNumber,
      required this.remoteOnLan,
      required this.autoUpdate,
      required this.updateTo,
      required this.vncSshAuth,
      required this.vncStatus,
      required this.vncPort,
      required this.twoWayCommunication,
      required this.remoteSupportEnabled,
      required this.remoteSupportPort,
      required this.remoteSupportIp,
      required this.remoteSupport,
      required this.productId,
      required this.vmc,
      required this.vid,
      required this.tempSensorConnected,
      required this.froniusDeviceType,
      required this.pL,
      required this.pdV,
      required this.inputType,
      required this.inputState});

  factory _VictronDevice.fromJson(Map<String, dynamic> json) {
    return _VictronDevice(
        name: json["name"],
        customName: json["customName"],
        productCode: json["productCode"],
        productName: json["productName"],
        idSite: json["idSite"],
        firmwareVersion: json["firmwareVersion"],
        lastConnection: json["lastConnection"],
        classDevice: json["class"],
        connection: json["connection"],
        instance: json["instance"],
        idDeviceType: json["idDeviceType"],
        settings: List<_VictronDeviceSettings>.from(
            json["settings"]?.map((x) => _VictronDeviceSettings.fromJson(x))),
        signalRSSI: json["signalRSSI"],
        signalSNR: json["signalSNR"],
        signalFrequency: json["signalFrequency"],
        antennaType: json["antennaType"],
        networkName: json["networkName"],
        loggingInterval: json["loggingInterval"],
        identifier: json["identifier"],
        lastPowerUpOrRestart: json["lastPowerUpOrRestart"],
        machineSerialNumber: json["machineSerialNumber"],
        remoteOnLan: json["remoteOnLan"],
        autoUpdate: json["autoUpdate"],
        updateTo: json["updateTo"],
        vncSshAuth: json["vncSshAuth"],
        vncStatus: json["vncStatus"],
        vncPort: json["vncPort"],
        twoWayCommunication: json["twoWayCommunication"],
        remoteSupportEnabled: json["remoteSupportEnabled"],
        remoteSupportPort: json["remoteSupportPort"],
        remoteSupportIp: json["remoteSupportIp"],
        remoteSupport: json["remoteSupport"],
        productId: json["productId"],
        vmc: json["vmc"],
        vid: (json["vid"] != null) ? _VictronVID.fromJson(json["vid"]) : null,
        tempSensorConnected: json["tempSensorConnected"],
        froniusDeviceType: json["froniousDeviceType"],
        pL: json["pL"],
        pdV: json["pdV"],
        inputType: json["inputType"],
        inputState: json["inputState"]);
  }
}

class _VDSecondsAgo {
  String? value, valueFormattedWithUnit;

  _VDSecondsAgo({required this.value, required this.valueFormattedWithUnit});

  factory _VDSecondsAgo.fromJson(Map<String, dynamic> json) {
    return _VDSecondsAgo(
        value: json["value"],
        valueFormattedWithUnit: json["valueFormattedWithUnit"]);
  }
}

class _VictronMeta {
  //
  Map<String, _VictronMetaProperty>? properties;

  _VictronMeta({this.properties});

  factory _VictronMeta.fromJson(Map<String, dynamic> json) {
    Map<String, _VictronMetaProperty> result = {};

    for (var key in json.keys) {
      result[key.toString()] =
          _VictronMetaProperty.fromJson(json[key.toString()]);
    }

    return _VictronMeta(properties: result);
  }
}

class _VictronMetaProperty {
  String? code, description, formatWithValueOnly, formatWithUnit;

  _VictronMetaProperty(
      {this.code,
      this.description,
      this.formatWithValueOnly,
      this.formatWithUnit});

  factory _VictronMetaProperty.fromJson(Map<String, dynamic> json) {
    return _VictronMetaProperty(
        code: json["code"],
        description: json["description"],
        formatWithValueOnly: json["formatWithValueOnly"],
        formatWithUnit: json["formatWithUnit"]);
  }
}

class _VictronVID {
  String? enumValue;
  _VictronVIDDevicesPerPhase devicesPerPhase;

  _VictronVID({required this.enumValue, required this.devicesPerPhase});

  factory _VictronVID.fromJson(Map<String, dynamic> json) {
    return _VictronVID(
        enumValue: json["enumValue"],
        devicesPerPhase:
            _VictronVIDDevicesPerPhase.fromJson(json["devicesPerPhase"]));
  }
}

class _VictronVIDDevicesPerPhase {
  _VictronVIDDevicesPerPhase();

  factory _VictronVIDDevicesPerPhase.fromJson(Map<String, dynamic> json) {
    return _VictronVIDDevicesPerPhase();
  }
}

class _VictronDeviceSettings {
  String? description, idDataAttribute, idDeviceType, idSite, loggedTimestamp;
  String? idUser, timestamp, username;
  int? loggedValue;
  int? value;
  List<int>? attributes;
  List<_VDSEnumData>? enumData;
  dynamic values;

  _VictronDeviceSettings(
      {required this.description,
      required this.enumData,
      required this.idDataAttribute,
      required this.idDeviceType,
      required this.idSite,
      required this.idUser,
      required this.loggedTimestamp,
      required this.loggedValue,
      required this.timestamp,
      required this.username,
      required this.value,
      required this.attributes,
      required this.values});

  factory _VictronDeviceSettings.fromJson(Map<String, dynamic> json) {
    return _VictronDeviceSettings(
        description: json["description"],
        enumData: List<_VDSEnumData>.from(
            json["enumData"]?.map((x) => _VDSEnumData.fromJson(x))),
        idDataAttribute: json["idDataAttribute"],
        idDeviceType: json["idDeviceType"],
        idSite: json["idSite"],
        idUser: json["idUser"],
        loggedTimestamp: json["loggedTimestamp"],
        loggedValue: json["loggedValue"],
        timestamp: json["timestamp"],
        username: json["user_name"],
        value: json["value"],
        attributes: json["attributes"],
        values: json["values"]);
  }
}

class _VDSEnumData extends _VictronEnum {
  String? nameEnum;
  int? valueEnum;
  _VDSValues? values;

  _VDSEnumData(
      {required this.nameEnum, required this.valueEnum, required this.values});

  factory _VDSEnumData.fromJson(Map<String, dynamic> json) {
    return _VDSEnumData(
        nameEnum: json["nameEnum"],
        valueEnum: json["valueEnum"],
        values: json["values"]?.map((x) => _VDSValues.fromJson(x)));
  }
}

class _VDSValues {
  int? property1, property2;
  _VDSValues({required this.property1, required this.property2});

  factory _VDSValues.fromJson(Map<String, dynamic> json) {
    return _VDSValues(
        property1: json["property1"], property2: json["property2"]);
  }
}

class _VictronUnconfiguredDevices {
  dynamic unconfiguredDevices;

  _VictronUnconfiguredDevices({required this.unconfiguredDevices});

  factory _VictronUnconfiguredDevices.fromValue(dynamic value) {
    if (value is bool) {
      return _VictronUnconfiguredDevices(unconfiguredDevices: value);
    } else {
      return _VictronUnconfiguredDevices(
          unconfiguredDevices: List<_VictronUnconfiguredDevice>.from(
              //(value as List<dynamic>).length,
              //(index) => _VictronUnconfiguredDevice.fromList(value[index])
              value?.map((x) => _VictronUnconfiguredDevice.fromJson(x))));
    }
  }
}

class _VictronUnconfiguredDevice {
  String idSite, instance, lastConnection, name;

  _VictronUnconfiguredDevice(
      {required this.idSite,
      required this.instance,
      required this.lastConnection,
      required this.name});

  factory _VictronUnconfiguredDevice.fromJson(Map<String, dynamic> json) {
    return _VictronUnconfiguredDevice(
        idSite: json["idSite"],
        instance: json["instance"],
        lastConnection: json["lastConnection"],
        name: json["name"]);
  }
}
