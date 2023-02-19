import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

/// Class that represents any device that can connect via Bluetooth
///
/// *** WORK IN PROGRESS ***
class BluetoothDevice {
  String? deviceId;
  String? deviceName;
  List<Uuid?>? services;
  List<QualifiedCharacteristic?>? characteristic;
  List<int?>? manufacturerData;

  bool connected = false;

  BluetoothDevice() {
    deviceId = "";
    deviceName = "";
    services = [null];
    characteristic = [null];
    manufacturerData = [];
  }

  BluetoothDevice.definedDevice(this.deviceId, this.deviceName, this.services,
      this.characteristic, this.manufacturerData);

  BluetoothDevice.fromDiscovered(DiscoveredDevice? device) {
    deviceId = device?.id;
    deviceName = device?.name;
    services = device?.serviceUuids;
    manufacturerData = device?.manufacturerData;
  }

  @override
  bool operator ==(Object other) {
    if (other is BluetoothDevice) {
      return deviceId == other.deviceId && deviceName == other.deviceName;
    } else {
      return false;
    }
  }

  @override
  int get hashCode => deviceId.hashCode;
}
