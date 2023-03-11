import 'package:texepcontrol/logic/api_victron.dart';

import 'api_service.dart';

class ApiServices {
  ApiServices();

  final List<ApiService> _services = [];
  Map<ApiServiceValues, ApiService> _serviceValues = {};
  final Map<String, String> _connectionResponse = {};

  List<ApiService> get getServices => _services;

  void addService(String service) {
    if (service == "Victron") {
      _services.add(ApiVictron());
    }
  }

  set setServiceValues(Map<ApiServiceValues, ApiService> value) =>
      _serviceValues = value;
  Map<ApiServiceValues, ApiService> get getServiceValues => _serviceValues;

  Map<String, String> get getConnectionResponse => _connectionResponse;
}

class ApiServiceValues {
  Map<ApiValues, String> values = {};

  ApiServiceValues(this.values);

  ApiServiceValues.fromString(Map<String, String> values) {
    this.values = _serviceValuesMap(values);
  }

  /// Converter Map<String,String> to Map<ApiValues, String>
  ///
  /// Method that converts a String Map, to a Map that can be used as ApiServiceValues
  /// For now it is incorrect, correct implementation found in api_victron.dart
  Map<ApiValues, String> _serviceValuesMap(Map<String, String> values) {
    Map<ApiValues, String> answer = {};

    for (var value in values.entries) {
      if (value.key == ApiValues.token.toString()) {
        answer[ApiValues.token] = value.value;
      } else if (value.key == ApiValues.idUser.toString()) {
        answer[ApiValues.idUser] = value.value;
      } else if (value.key == ApiValues.verification.toString()) {
        answer[ApiValues.verification] = value.value;
      } else if (value.key == ApiValues.twoFactorAuth.toString()) {
        answer[ApiValues.twoFactorAuth] = value.value;
      }
    }

    return answer;
  }
}

enum ApiValues { token, idUser, verification, twoFactorAuth }
