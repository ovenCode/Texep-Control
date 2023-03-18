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
    // TODO: implement createToken
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
    // TODO: implement requestSites
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
    // TODO: implement request site devices
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
        final Map<dynamic, dynamic> mapJson = jsonDecode(response.body);
        log("ApiVictron::requestSiteDevices::result: ${mapJson.toString()}");
        for (var value in mapJson.entries) {
          if (value.key == "records") {
            for (var record in (value.value as Map<dynamic, dynamic>).entries) {
              if (record.key == "devices") {
                for (int i = 0;
                    i < (record.value as List<dynamic>).length;
                    i++) {
                  for (var entry
                      in (record.value[i] as Map<dynamic, dynamic>).entries) {
                    if (entry.key == "productName") {
                      _deviceNames["productName$i"] = entry.value;
                    }
                  }
                }
              }
            }
          }
        }
        log("ApiVictron::requestSiteDevices: String of devices ${_deviceNames.toString()}");
        return "Success";
      } else {
        log("ApiVictron::requestSiteDevices: Error ${response.statusCode} ${response.body.toString()}");
      }
    } catch (e) {
      throw e.toString();
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
            _ApiVictronResponse("List of connected devices", mapJson);
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
        log("ApiVictron::requestSiteStats: This is the object responseVictron: ${responseVictron.toString()}");
        log("RESPONSES: ${responseVictron.getResponses.toString()}");
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
  String? errorCode;
  dynamic errors;

  final Map<String, dynamic> _responses = {};
  _ApiVictronResponse(String type, Map<String, dynamic> json) {
    if (json["success"] == true) {
      _ApiVictronResponse.isSuccessful(
          success: json["success"],
          records: _VictronResponseRecords(type, json["records"]));
      if (records != null) {
        _setResponse(VRMAPI_CONNECTED_DEVICES, records!);
      }
    } else {
      _ApiVictronResponse.isUnsuccessful(
          success: json["success"],
          errors: json["errors"],
          errorCode: json["error_code"]);
    }
  }
  _ApiVictronResponse.isSuccessful(
      {required this.success, required this.records});

  _ApiVictronResponse.isUnsuccessful(
      {required this.success, required this.errors, required this.errorCode});

  void _setResponse(int code, _VictronResponseRecords records) {
    switch (code) {
      case VRMAPI_CONNECTED_DEVICES:
        _responses["connected_devices"] = records;
        break;
      default:
    }
  }

  Map<String, dynamic> get getResponses => _responses;
}

/// Records part of a response body
class _VictronResponseRecords {
  List<_VictronDevice>? victronDevices;
  _VictronUnconfiguredDevices? victronUnconfiguredDevices;
  String? token;

  _VictronResponseRecords(String type, Map<String, dynamic> records) {
    if (type == "List of connected devices") {
      victronDevices = records["devices"];
      victronUnconfiguredDevices = records["unconfigured_devices"];
    } else if (type == "Login to Victron") {
      // TODO: implement response for connect()
    } else if (type == "Installation stats") {
      // TODO: implement response for requestSites()
    }
  }
}

class _VictronDevice {
  String name,
      productCode,
      productName,
      firmwareVersion,
      classDevice,
      connection,
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
  String? customName;
  int idSite, instance, idDeviceType, vncPort;
  bool vncSshAuth,
      twoWayCommunication,
      remoteSupportEnabled,
      tempSensorConnected;
  _VictronVID vid;
  dynamic lastConnection,
      loggingInterval,
      lastPowerUpOrRestart,
      machineSerialNumber,
      remoteSupportPort,
      productId,
      vmc,
      pL,
      inputType;
  List<_VictronDeviceSettings> settings;

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
        settings: List<_VictronDeviceSettings>.generate(
            (json["settings"] as List<dynamic>).length,
            (index) =>
                _VictronDeviceSettings.fromJson(json["settings"][index])),
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
        vid: _VictronVID.fromJson(json["vid"]),
        tempSensorConnected: json["tempSensorConnected"],
        froniusDeviceType: json["froniousDeviceType"],
        pL: json["pL"],
        pdV: json["pdV"],
        inputType: json["inputType"],
        inputState: json["inputState"]);
  }
}

class _VictronVID {
  _VictronVID();

  factory _VictronVID.fromJson(Map<String, dynamic> json) {
    return _VictronVID();
  }
}

class _VictronDeviceSettings {
  String description, idDataAttribute, idDeviceType, idSite, loggedTimestamp;
  String? idUser, timestamp, username;
  int loggedValue;
  int? value;
  List<int> attributes;
  List<_VDSEnumData> enumData;
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
        enumData: List<_VDSEnumData>.generate(
            (json["enumData"] as List<dynamic>).length,
            (index) => _VDSEnumData.fromJson(json["enumData"][index])),
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

class _VDSEnumData {
  String nameEnum;
  int valueEnum;
  _VDSValues values;

  _VDSEnumData(
      {required this.nameEnum, required this.valueEnum, required this.values});

  factory _VDSEnumData.fromJson(Map<String, dynamic> json) {
    return _VDSEnumData(
        nameEnum: json["nameEnum"],
        valueEnum: json["valueEnum"],
        values: _VDSValues.fromJson(json["values"]));
  }
}

class _VDSValues {
  int property1, property2;
  _VDSValues({required this.property1, required this.property2});

  factory _VDSValues.fromJson(Map<String, dynamic> json) {
    return _VDSValues(
        property1: json["property1"], property2: json["property2"]);
  }
}

class _VictronUnconfiguredDevices {
  dynamic unconfiguredDevices;

  _VictronUnconfiguredDevices({required this.unconfiguredDevices});

  factory _VictronUnconfiguredDevices.fromJson(Map<String, dynamic> json) {
    if (json["unconfigured_devices"] is bool) {
      return _VictronUnconfiguredDevices(
          unconfiguredDevices: json["unconfigured_devices"]);
    } else {
      return _VictronUnconfiguredDevices(
          unconfiguredDevices: List<_VictronUnconfiguredDevice>.generate(
              (json["unconfigured_devices"] as List<dynamic>).length,
              (index) => _VictronUnconfiguredDevice.fromJson(
                  json["unconfigured_devices"][index])));
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
