import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:texepcontrol/logic/bluetooth_device.dart';
import 'package:texepcontrol/logic/bluetooth_exceptions.dart';
import 'package:texepcontrol/logic/bluetooth_manager.dart';

class DeviceView extends StatefulWidget {
  final BluetoothDevice bluetoothDevice;
  final Stream<ConnectionStateUpdate>? connectionStream;
  const DeviceView(
      {required Key key, required this.bluetoothDevice, this.connectionStream})
      : super(key: key);
  //DeviceView(this.connectionStream,this.bluetoothDevice);

  @override
  State<DeviceView> createState() => _DeviceViewState();
}

class _DeviceViewState extends State<DeviceView> {
  late BluetoothDevice bluetoothDevice;
  Stream<ConnectionStateUpdate>? connectionStream = const Stream.empty();
  List<int>? values = [];
  final BluetoothManager manager = BluetoothManager();
  //_DeviceViewState();
  @override
  void initState() {
    connectionStream = widget.connectionStream as Stream<ConnectionStateUpdate>;
    bluetoothDevice = widget.bluetoothDevice;
    super.initState();
    getCharacteristic().then((value) => values = value, onError: (e) {
      (e as ReadingException).showErrorDialog(context, e.errorInfo);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final arguments = (ModalRoute.of(context)?.settings.arguments ??
    //     <String, dynamic>{}) as Map;

    //bluetoothDevice = arguments['bluetoothDevice'];
    log("ConnectionStream Information: ");
    log(connectionStream?.isBroadcast.toString() ?? "");

    return Scaffold(
      appBar: AppBar(
        title: Text(bluetoothDevice.deviceName.toString()),
      ),
      body: StreamBuilder(
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
                    try {
                      return FutureBuilder(
                        builder: (context, snapshot) {
                          log("DeviceView::FutureBuilder: Succesfully in FutureBuilder. Attempting to read values");
                          //try
                          if (snapshot.hasData) {
                            log("Getting message value");
                            return Text(snapshot.data.toString());
                          } else if (snapshot.hasError) {
                            throw ReadingException(snapshot.error.toString());
                          }
                          return const Text("No values");
                        },
                      );
                    } on ReadingException catch (e) {
                      e.showErrorDialog(context, e.errorInfo);
                    }

                    //   manager
                    //       .readCharacteristic(
                    //           int.tryParse(
                    //                   bluetoothDevice.deviceId.toString()) ??
                    //               0,
                    //           0)
                    //       .then((value) {
                    //     log("DeviceView::ReadCharacteristic: Assigning read values");
                    //     values = value;
                    //   });
                    //   if (values != null) {
                    //     return Text(values![index].toString());
                    //   }
                    //   return const Text("No values");
                    // }
                    // return Text(snapshot.data.toString());
                  }
                  return null;
                });
          } else if (snapshot.hasError) {
            log("DeviceView::SnapshotError: Getting Error");
            throw ConnectionException(snapshot.error.toString());
          } else if (snapshot.connectionState == ConnectionState.done) {
            return const Text("Done.");
          } else {
            return Text("Some other error. ${snapshot.toString()}");
          }
        },
      ),
    );
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

  Future<List<int>> getCharacteristic() {
    final Future<List<int>> answer;
    try {
      answer = manager.readCharacteristic(
          int.tryParse(bluetoothDevice.deviceId ?? "0") ?? 0, 0);
    } catch (e) {
      throw ReadingException(e.toString());
    }
    return answer;
  }
}

class DeviceViewArguments {
  final BluetoothDevice bluetoothDevice;
  final Stream<ConnectionStateUpdate>? connectionStream;
  final Key key;

  DeviceViewArguments(this.key, this.bluetoothDevice, this.connectionStream);
}
