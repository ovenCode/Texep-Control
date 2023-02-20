import 'dart:async';
import 'dart:developer';
import 'dart:io' show Platform;
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:texepcontrol/logic/bluetooth_device.dart';
import 'package:texepcontrol/logic/bluetooth_exceptions.dart';

/// Class that represents a device manager that can connect to specific
/// devices via Bluetooth
///
/// *** WORK IN PROGRESS ***
class BluetoothManager {
  final flutterReactiveBle = FlutterReactiveBle();
  String? status = "";
  List<BluetoothDevice?>? devices = [];
  DiscoveredDevice? searchDevice;
  StreamSubscription<DiscoveredDevice?>? scanStreamSub;
  Stream<DiscoveredDevice?>? scanStream;

  bool scanStarted = false;

  BluetoothManager();

  String? getStatus() {
    flutterReactiveBle.statusStream.listen((statusInfo) {
      status = statusInfo.toString();
    });

    return flutterReactiveBle.status.toString();
  }

  Future<void> checkPermissons() async {
    if (Platform.isAndroid) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
        Permission.bluetoothScan,
        Permission.bluetoothConnect
      ].request();

      for (var status in statuses.entries) {
        if (status.key == Permission.location) {
          if (status.value.isGranted) {
            log("Location permission is granted");
          } else {
            log("Location permission not granted");
          }
        } else if (status.key == Permission.bluetoothScan) {
          if (status.value.isGranted) {
            log("Bluetooth scan permission granted");
          } else {}
        } else if (status.key == Permission.bluetoothConnect) {
          if (status.value.isGranted) {
            log("Bluetooth connect permission granted");
          } else {
            log("Bluetooth connect permission not granted");
          }
        }
      }
    }
  }

  Future<List<BluetoothDevice?>?> deviceSearch() async {
    log("BluetoothManager: Starting scan for devices");
    scanStreamSub = flutterReactiveBle.scanForDevices(
        withServices: [], scanMode: ScanMode.lowLatency).listen((device) {
      // handling
      devices?.add(BluetoothDevice.definedDevice(device.id, device.name,
          device.serviceUuids, [], device.manufacturerData));
      searchDevice = device;
      devices?.add(BluetoothDevice.fromDiscovered(searchDevice));
    }, onError: (e) {
      // error handling
      throw ScanException(e.toString());
    });

    return devices;
  }

  Stream<DiscoveredDevice> deviceSearchStream() async* {
    log("BluetoothManager: Starting scan for devices");
    scanStreamSub = flutterReactiveBle.scanForDevices(
        withServices: [], scanMode: ScanMode.balanced).listen((device) {
      // handling
      // devices?.add(BluetoothDevice.definedDevice(device.id, device.name,
      //     device.serviceUuids, [null], device.manufacturerData));
      searchDevice = device;
      if (devices?.contains(BluetoothDevice.fromDiscovered(searchDevice)) ==
          false) {
        devices?.add(BluetoothDevice.fromDiscovered(searchDevice));
      }
    }, onError: (e) {
      // error handling
      scanStreamSub?.cancel();
      throw ScanException(e.toString());
    });
    await for (var device
        in flutterReactiveBle.scanForDevices(withServices: [])) {
      yield device;
    }
  }

  void stopScan() {
    scanStreamSub?.cancel();
  }

  Stream<ConnectionStateUpdate> connectToDevice(
      foundDeviceId, serviceIds, connectionTimeout) {
    log("BluetoothManager: Attempting to connect to device: ");
    Stream<ConnectionStateUpdate> connectionStream =
        flutterReactiveBle.connectToDevice(
            id: foundDeviceId,
            servicesWithCharacteristicsToDiscover: serviceIds,
            connectionTimeout: connectionTimeout);
    return connectionStream;
  }

  StreamSubscription<ConnectionStateUpdate> connectToDeviceSub(
      foundDeviceId, serviceIds, connectionTimeout) {
    log("BluetoothManager: Attempting to connect to device: ");
    StreamSubscription<ConnectionStateUpdate> connectionStream =
        flutterReactiveBle
            .connectToDevice(
                id: foundDeviceId,
                servicesWithCharacteristicsToDiscover: serviceIds,
                connectionTimeout: connectionTimeout)
            .listen((connectionState) {
      if (connectionState.connectionState == DeviceConnectionState.connecting) {
        log("BluetoothManager: Connecting to device...");
      }
      if (connectionState.connectionState == DeviceConnectionState.connected) {
        log("BluetoothManager: Connection success");
      }

      // handling
    }, onError: (e) {
      // error handling
      throw ConnectionException(e.toString());
    });

    return connectionStream;
  }

  Future<List<int>> readCharacteristic(
      int deviceId, int characteristicId) async {
    List<int> answer = await flutterReactiveBle.readCharacteristic(
        devices?[deviceId]?.characteristic?[characteristicId]
            as QualifiedCharacteristic);

    return answer;
  }
}
