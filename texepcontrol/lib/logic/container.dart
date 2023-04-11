import 'package:texepcontrol/logic/api_service.dart';
import 'package:texepcontrol/logic/api_services.dart';
import 'package:texepcontrol/logic/iservice.dart';

import '../utils/languages/ilanguage.dart';
import '../utils/languages/language_eng.dart';
import '../utils/languages/language_fr.dart';

///
/// ** WORK IN PROGRESS **
///
/// This is the container that operates with all the data
/// that is used by the program
///

class Container {
  Container();

  // Services initialization

  final ApiServices _apiServices = ApiServices();
  Object response = Object();

  // Language setup

  ILanguage? language;

  void setLanguage(String lang) {
    switch (lang) {
      case "ENG":
        language = LanguageEng();
        break;
      default:
    }
    if (lang == "ENG") {
      language = LanguageEng();
    } else if (lang == "FR") {
      language = LanguageFr();
    }
  }

  // Language getter

  ILanguage get getLanguage => language!;

  // Service methods

  // Service getters and setters

  /// List of ApiService
  ///
  /// Function returns all ApiService registered in ApiServices.
  /// Probably will be a Map<String, String> later until then it's List<ApiService>
  List<ApiService> get getServices => _apiServices.getServices;

  // Other methods

  /// Adds a new sevice.
  /// Used for adding a service based on the parameter.
  /// If new services are implemented add a new case here.
  void addService(String service) {
    switch (service) {
      case "Victron":
        _apiServices.addService(service);
        break;
      default:
        break;
    }
  }

  /// Get specific response from service
  ///
  /// Function returns a response of type Object
  /// containing important information
  Object getResponse(IService service) => response;
}
