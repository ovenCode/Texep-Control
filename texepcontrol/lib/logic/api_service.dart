import 'iservice.dart';

abstract class ApiService implements IService {
  bool isUserDefined = false;

  set setUser(Map<String, String> val);

  /// Connection
  ///
  /// Method to connect to the API Service
  Stream<String> connect();

  /// Connection
  ///
  /// Method to disconnect from the API Service
  void disconnect();
  Map<String, String> get getConnectionResponse;

  /// requestSites
  ///
  /// method to request installation sites
  Future<String> requestSites();

  Map<String, String> get getSites;

  Future<String> requestSiteDevices(String siteId);

  Map<String, String> get getDeviceNames;

  Future<String> requestSiteStats(String siteId);

  Map<String, String> get getDeviceStats;
}
