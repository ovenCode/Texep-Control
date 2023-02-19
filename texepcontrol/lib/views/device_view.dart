import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:texepcontrol/logic/bluetooth_device.dart';

class DeviceView extends StatefulWidget {
  final BluetoothDevice bluetoothDevice;
  const DeviceView({required Key key, required this.bluetoothDevice})
      : super(key: key);

  @override
  State<DeviceView> createState() => _DeviceViewState();
}

class _DeviceViewState extends State<DeviceView> {
  late BluetoothDevice bluetoothDevice;
  _DeviceViewState();
  @override
  void initState() {
    super.initState();
    bluetoothDevice = widget.bluetoothDevice;
    log("DeviceViewState::initState: bluetoothDevice ${bluetoothDevice.deviceId.toString()}");
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    bluetoothDevice = arguments['bluetoothDevice'];
    return Scaffold(
      appBar: AppBar(
        title: Text(bluetoothDevice.deviceName.toString()),
      ),
      body: Column(children: [
        Text(bluetoothDevice.deviceId.toString()),
        Text(bluetoothDevice.deviceName.toString()),
        Text(bluetoothDevice.manufacturerData.toString()),
        Expanded(
          child: ListView.builder(
            itemCount: bluetoothDevice.services?.length,
            itemBuilder: (context, index) {
              return Center(
                child: SizedBox(
                  height: 50,
                  child: Text(
                      bluetoothDevice.services?[index]?.data.toString() ??
                          "no services"),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}
