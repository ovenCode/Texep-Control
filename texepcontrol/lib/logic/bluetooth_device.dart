import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

/// Class that represents any device that can connect via Bluetooth
///
/// *** WORK IN PROGRESS ***
class BluetoothDevice {
  String? deviceId;
  String? deviceName;
  List<Uuid?>? services;
  List<QualifiedCharacteristic?>? characteristic;

  BluetoothDevice() {
    deviceId = "";
    deviceName = "";
    services = [null];
    characteristic = [null];
  }

  BluetoothDevice.definedDevice(
      this.deviceId, this.deviceName, this.services, this.characteristic);
}
