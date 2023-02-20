import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:texepcontrol/logic/bluetooth_device.dart';
import 'package:texepcontrol/logic/bluetooth_exceptions.dart';
import 'package:texepcontrol/logic/bluetooth_manager.dart';

class DeviceView extends StatefulWidget {
  final BluetoothDevice bluetoothDevice;
  final StreamSubscription<ConnectionStateUpdate>? connectionStream;
  const DeviceView(
      {required Key key, required this.bluetoothDevice, this.connectionStream})
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
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    Stream<ConnectionStateUpdate> connectionStream;
    BluetoothManager manager = BluetoothManager();
    List<int>? values;

    bluetoothDevice = arguments['bluetoothDevice'];
    connectionStream = arguments['connectionStream'];

    return Scaffold(
        appBar: AppBar(
          title: Text(bluetoothDevice.deviceName.toString()),
        ),
        body: Center(
          child: StreamBuilder(
            stream: connectionStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: bluetoothDevice.characteristic?.length,
                  itemBuilder: (context, index) {
                    log("DeviceView::SnapshotData: Snapshot has data. Starting connection check.");
                    if (snapshot.data?.connectionState ==
                        DeviceConnectionState.connected) {
                      log("DeviceView::Device: Device connected, attempting to read characteristics.");
                      manager
                          .readCharacteristic(
                              int.tryParse(
                                      bluetoothDevice.deviceId.toString()) ??
                                  0,
                              0)
                          .then((value) {
                        log("DeviceView::ReadCharacteristic: Assigning read values");
                        values = value;
                      });
                      if (values != null) {
                        return Text(values![index].toString());
                      }
                      return const Text("No values");
                    }
                    return Text(snapshot.data.toString());
                  },
                );
              } else if (snapshot.hasError) {
                log("DeviceView::SnapshotError: Getting Error");
                throw ConnectionException(snapshot.error.toString());
              } else {
                return const Text("Some other error");
              }
            },
          ),
        ));
    // if (connectionStream != null) {
    //   connectionStream.onData(
    //     (data) async {
    //       if (data.connectionState == DeviceConnectionState.connected) {
    //         log("DeviceView::connectionStream: Device is connected. Attempting to read characteristic");
    //         values = await manager.readCharacteristic(
    //             bluetoothDevice.deviceId as int, 0);
    //       }
    //     },
    //   );
    //   connectionStream.onError((e) {
    //     throw ConnectionException(e.toString());
    //   });
    //   return Scaffold(
    //       appBar: AppBar(
    //         title: Text(bluetoothDevice.deviceName.toString()),
    //       ),
    //       body: Column(children: [
    //         const Text("This is live data"),
    //         Text(bluetoothDevice.characteristic.toString()),
    //         Text("Characteristic value ${values.toString()}"),
    //       ]));
    // } else {
    //   log("DeviceView::connectionStream: Unfortunately connectionStream is null");
    //   return Scaffold(
    //     appBar: AppBar(
    //       title: Text(bluetoothDevice.deviceName.toString()),
    //     ),
    //     body: Column(children: [
    //       Text(bluetoothDevice.deviceId.toString()),
    //       Text(bluetoothDevice.deviceName.toString()),
    //       Text(bluetoothDevice.manufacturerData.toString()),
    //       Text(bluetoothDevice.characteristic.toString()),
    //       Expanded(
    //         child: ListView.builder(
    //           itemCount: bluetoothDevice.services?.length,
    //           itemBuilder: (context, index) {
    //             return Center(
    //               child: SizedBox(
    //                 height: 50,
    //                 child: Text(
    //                     bluetoothDevice.services?[index]?.data.toString() ??
    //                         "no services"),
    //               ),
    //             );
    //           },
    //         ),
    //       ),
    //       Expanded(
    //         child: ListView.builder(
    //           itemCount: bluetoothDevice.characteristic?.length,
    //           itemBuilder: (context, index) {
    //             return Center(
    //               child: SizedBox(
    //                 height: 50,
    //                 child: Text(
    //                     bluetoothDevice.characteristic?[index]?.toString() ??
    //                         "no characteristic"),
    //               ),
    //             );
    //           },
    //         ),
    //       ),
    //     ]),
    //   );
    // }
  }
}
