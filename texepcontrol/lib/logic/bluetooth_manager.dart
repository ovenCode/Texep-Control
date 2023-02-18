import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:texepcontrol/logic/bluetooth_device.dart';
import 'package:texepcontrol/logic/bluetooth_exceptions.dart';

/// Class that represents a device manager that can connect to specific
/// devices via Bluetooth
///
/// *** WORK IN PROGRESS ***
class BluetoothManager {
  final flutterReactiveBle = FlutterReactiveBle();
  List<BluetoothDevice?>? devices;

  BluetoothManager();

  Future<List<BluetoothDevice?>?> deviceSearch() async {
    flutterReactiveBle.scanForDevices(
        withServices: [], scanMode: ScanMode.balanced).listen((device) {
      // handling
      devices?.add(BluetoothDevice.definedDevice(
          device.id, device.name, device.serviceUuids, [null]));
    }, onError: (e) {
      // error handling
      throw ScanException(e);
    });

    return devices;
  }

  BluetoothDevice connectToDevice(
      foundDeviceId, serviceIds, connectionTimeout) {
    BluetoothDevice device = BluetoothDevice();
    flutterReactiveBle
        .connectToDevice(
            id: foundDeviceId,
            servicesWithCharacteristicsToDiscover: serviceIds,
            connectionTimeout: connectionTimeout)
        .listen((connectionState) {
      device = BluetoothDevice();

      // handling
    }, onError: (e) {
      // error handling
      throw ConnectionException();
    });

    return device;
  }
}
