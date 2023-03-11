import 'dart:async';
import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:texepcontrol/constants/colors.dart';
import 'package:texepcontrol/constants/routes.dart';
import 'package:texepcontrol/logic/api_services.dart';
import 'package:texepcontrol/logic/bluetooth_device.dart';
import 'package:texepcontrol/logic/bluetooth_exceptions.dart';
import 'package:texepcontrol/logic/bluetooth_manager.dart';
import 'package:texepcontrol/utils/devlog.dart';
import 'package:texepcontrol/views/device_view.dart';
import 'package:texepcontrol/views/login_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  BluetoothManager manager = BluetoothManager();

  try {
    manager.getStatus.listen((event) {
      if (event == BleStatus.ready) {
        log("main: BluetoothManager is ready, starting app.");
        runApp(MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              primarySwatch: ColorsExt.brown500Swatch,
            ),
            home: const MyHomePage(title: 'Texep Control'),
            routes: {
              homePageRoute: (context) =>
                  const MyHomePage(title: 'Texep Control'),
              sideBarRoute: (context) => const SideBarMenu(),
              // deviceViewRoute: (
              //   context,
              // ) =>
              //     DeviceView(key: UniqueKey(), bluetoothDevice: BluetoothDevice()),
              loginViewRoute: (context) => LoginView(
                    apiServices: apiServices,
                  ),
            },
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case deviceViewRoute:
                  final DeviceViewArguments arguments =
                      settings.arguments as DeviceViewArguments;
                  Map<Object?, WidgetBuilder> routes = <Object?, WidgetBuilder>{
                    "deviceView": (ctx) => DeviceView(
                        key: arguments.key,
                        bluetoothDevice: arguments.bluetoothDevice,
                        connectionStream: arguments.connectionStream),
                  };
                  WidgetBuilder builder =
                      routes[settings.name] as WidgetBuilder;

                  return MaterialPageRoute(
                      builder: (ctx) => builder(ctx), settings: settings);
                case homePageRoute:
                  return MaterialPageRoute(
                    builder: (context) =>
                        const MyHomePage(title: "Texep Control"),
                    settings: settings,
                  );
                default:
                  return MaterialPageRoute(
                    builder: (context) =>
                        const MyHomePage(title: "Texep Control"),
                    settings: settings,
                  );
              }
            }));
      } else if (event == BleStatus.unauthorized) {
        log("BluetoothManager: Status was unauthorized");
        manager.checkPermissons();
      } else if (event == BleStatus.unknown) {
        manager.checkPermissons();
      } else {
        throw BluetoothException(event.toString());
      }
    });
  } on BluetoothException catch (e) {
    log(e.errorInfo);
  }
}

ApiServices apiServices = ApiServices();

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;
  final String buttonTitle = "";

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  static const List<Tab> myTabs = <Tab>[
    Tab(text: 'LOCAL'),
    Tab(text: 'REMOTE'),
  ];

  late TabController _tabController;
  BluetoothManager manager = BluetoothManager();
  List<BluetoothDevice> bluetoothDevices = [];
  Stream<DiscoveredDevice> scannedDevices = const Stream.empty();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: myTabs.length,
      vsync: this,
    );
    scannedDevices =
        manager.deviceSearchStream().distinct().asBroadcastStream();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  // leading: IconButton(
  //         icon: const Icon(
  //           Icons.menu,
  //           color: Colors.white,
  //         ), //Icons.menu,
  //         onPressed: () {
  //           try {
  //             Navigator.of(context).pushNamedAndRemoveUntil(
  //               sideBarRoute,
  //               (route) => false,
  //             );
  //           } catch (e) {
  //             log(e.toString());
  //           }

  //           Builder(builder: (context) {
  //             log("MyHomePage: Building SideBar inside IconButton.onPressed");
  //             return Center(
  //                 child: Column(
  //               children: [
  //                 TextButton(
  //                   onPressed: () {},
  //                   child: const Text("Devices"),
  //                 ),
  //                 TextButton(
  //                   onPressed: () {},
  //                   child: const Text("Settings"),
  //                 ),
  //               ],
  //             ));
  //           });
  //         },
  //       ),
  // Center(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: const [
  //           Text("No devices"),
  //         ],
  //       ),
  //     ),

  @override
  Widget build(BuildContext context) {
    super.build(context);
    log("MyHomePage: Building HomePage");

    // try {
    //   log("MyHomePage::1stTryCatch: Trying to get devices");
    //   Future<List<BluetoothDevice?>?> getDevices =
    //       Future(() async => manager.deviceSearch());
    //   getDevices.then(
    //       (value) => {
    //             Scaffold(
    //                 appBar: AppBar(),
    //                 body: Center(
    //                   child: Column(
    //                     children: [
    //                       ListView.builder(
    //                         itemBuilder: (context, index) {
    //                           return SizedBox(
    //                             height: 40,
    //                             child: Center(
    //                               child: Text("Entry ${value?[index]}"),
    //                             ),
    //                           );
    //                         },
    //                       ),
    //                       Center(
    //                         child: Text("Bluetooth status: ${manager.status}"),
    //                       ),
    //                     ],
    //                   ),
    //                 ))
    //           }, onError: (e) {
    //     throw ScanException(e);
    //   });
    // } on ScanException catch (e) {
    //   e.showErrorDialog(context, e.toString());
    // }

    // return DefaultTabController(
    //     length: myTabs.length,
    //     child: Builder(
    //       builder: (context) {
    //         final TabController controller = DefaultTabController.of(context);
    //         controller.addListener(() {
    //           if (!controller.indexIsChanging) {}
    //         });

    //         return Scaffold(
    //             appBar: AppBar(
    //               title: const Text("Texep Control"),
    //               bottom: const TabBar(
    //                 tabs: myTabs,
    //               ),
    //             ),
    //             body: Center(
    //               child: Column(
    //                 children: [
    //                   Center(
    //                     heightFactor: 4,
    //                     child: Text("Bluetooth status: ${manager.getStatus()}"),
    //                   ),
    //                   Expanded(
    //                       child: ListView.builder(
    //                     itemCount: myTabs.length,
    //                     itemBuilder: (context, index) {
    //                       return SizedBox(
    //                         height: 20,
    //                         child: Center(
    //                           child: Text("Entry ${myTabs[index]}"),
    //                         ),
    //                       );
    //                     },
    //                   )),
    //                 ],
    //               ),
    //             ));
    //       },
    //     ));

    return DefaultTabController(
        length: myTabs.length,
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            bottom: TabBar(
              tabs: myTabs,
              controller: _tabController,
            ),
          ),
          drawer: Drawer(
            child: ListView(
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text("Devices"),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text("Settings"),
                ),
              ],
            ),
          ),
          body: TabBarView(controller: _tabController, children: [
            Center(
                child: StreamBuilder(
              stream: scannedDevices,
              builder: (context, snapshot) {
                try {
                  if (snapshot.hasData) {
                    //log("MyHomePage::StreamBuilder: Snapshot has data: ${snapshot.data.toString()}");
                    if (!bluetoothDevices.contains(
                        BluetoothDevice.fromDiscovered(snapshot.data))) {
                      log("ListViewBuilder: Got device ${snapshot.data}");
                      bluetoothDevices
                          .add(BluetoothDevice.fromDiscovered(snapshot.data));
                    }
                    return ListView.builder(
                      itemCount: bluetoothDevices.length,
                      itemBuilder: (context, index) {
                        return SizedBox(
                          height: 30,
                          child: Center(
                            child: TextButton(
                              child: Text(
                                "${bluetoothDevices[index].deviceName} ${bluetoothDevices[index].deviceId}",
                              ),
                              onPressed: () {
                                manager.stopScan();
                                changeTitle(bluetoothDevices[index]);
                                // Navigator.pushNamed(context, "deviceView",
                                //     arguments: DeviceViewArguments(
                                //         UniqueKey(),
                                //         bluetoothDevices[index],
                                //         manager.connectToDevice(
                                //             bluetoothDevices[index]
                                //                 .deviceId,
                                //             null,
                                //             const Duration(seconds: 8)))
                                // {
                                //   "bluetoothDevice":
                                //       bluetoothDevices[index],
                                //   "connectionStream":
                                //       manager.connectToDevice(
                                //           bluetoothDevices[index]
                                //               .deviceId,
                                //           null,
                                //           const Duration(seconds: 8))
                                //   //   BluetoothDevice.definedDevice(
                                //   // bluetoothDevices[index].deviceId,
                                //   // bluetoothDevices[index]
                                //   //     .deviceName,
                                //   // bluetoothDevices[index].services,
                                //   // [],
                                //   // bluetoothDevices[index]
                                //   //     .manufacturerData,
                                //   // )
                                // }
                                //);
                              },
                            ),
                          ),
                        );
                      },
                    );
                    //}
                  } else if (snapshot.hasError) {
                    log(snapshot.error.toString());
                    throw ScanException(snapshot.error.toString());
                  }
                } on ScanException catch (e) {
                  e.showErrorDialog(context, e.toString());
                }
                return const Text("No exceptions");
              },
            )),
            Center(child: Builder(
              builder: (context) {
                Devlog("MyHomePage::Tab2: Building Tab2 Test");
                Map<String, String> values = {};

                Future.delayed(
                  Duration.zero,
                  () async {
                    apiServices.addService("Victron");
                    if (apiServices.getServices.isNotEmpty) {
                      //
                      values = await Navigator.pushNamedAndRemoveUntil(
                              context, loginViewRoute, (route) => route.isFirst,
                              arguments: {"services": apiServices})
                          as Map<String, String>;

                      log("MyHomePageState::Remote: Token is ${values["token"]}");

                      apiServices.setServiceValues = {
                        ApiServiceValues.fromString(values):
                            apiServices.getServices[0],
                      };
                      log(apiServices.getServiceValues.toString());

                      if (values.isNotEmpty) {
                        List<String> sites = ["Test"];
                        log("Building sites list");
                        (apiServices.getServices[0]).requestSites();
                        return ListView.builder(
                          itemCount: sites.length,
                          itemBuilder: (context, index) => SizedBox(
                              height: 30,
                              child: Center(
                                  child: TextButton(
                                child: Text(sites[index]),
                                onPressed: () {},
                              ))),
                        );
                      }
                    }
                  },
                );

                return const Scaffold();
                //return const Text("Not setup yet.");
              },
            ))
          ] //myTabs.map((Tab tab) {
              // if (tab.text == "LOCAL") {
              //   log("MyHomePage::TabBarView::LocalTab: Entered TabBarView. Trying to get devices");

              //   return Center(
              //       child: StreamBuilder(
              //     stream: scannedDevices,
              //     builder: (context, snapshot) {
              //       try {
              //         if (snapshot.hasData) {
              //           //log("MyHomePage::StreamBuilder: Snapshot has data: ${snapshot.data.toString()}");
              //           if (!bluetoothDevices.contains(
              //               BluetoothDevice.fromDiscovered(snapshot.data))) {
              //             log("ListViewBuilder: Got device ${snapshot.data}");
              //             bluetoothDevices.add(
              //                 BluetoothDevice.fromDiscovered(snapshot.data));
              //           }
              //           return ListView.builder(
              //             itemCount: bluetoothDevices.length,
              //             itemBuilder: (context, index) {
              //               widget.buttonTitle =
              //                   "${bluetoothDevices[index].deviceName} ${bluetoothDevices[index].deviceId}";
              //               return SizedBox(
              //                 height: 30,
              //                 child: Center(
              //                   child: TextButton(
              //                     child: Text(
              //                       widget.buttonTitle,
              //                     ),
              //                     onPressed: () {
              //                       manager.stopScan();
              //                       changeTitle(bluetoothDevices[index]);
              //                       // Navigator.pushNamed(context, "deviceView",
              //                       //     arguments: DeviceViewArguments(
              //                       //         UniqueKey(),
              //                       //         bluetoothDevices[index],
              //                       //         manager.connectToDevice(
              //                       //             bluetoothDevices[index]
              //                       //                 .deviceId,
              //                       //             null,
              //                       //             const Duration(seconds: 8)))
              //                       // {
              //                       //   "bluetoothDevice":
              //                       //       bluetoothDevices[index],
              //                       //   "connectionStream":
              //                       //       manager.connectToDevice(
              //                       //           bluetoothDevices[index]
              //                       //               .deviceId,
              //                       //           null,
              //                       //           const Duration(seconds: 8))
              //                       //   //   BluetoothDevice.definedDevice(
              //                       //   // bluetoothDevices[index].deviceId,
              //                       //   // bluetoothDevices[index]
              //                       //   //     .deviceName,
              //                       //   // bluetoothDevices[index].services,
              //                       //   // [],
              //                       //   // bluetoothDevices[index]
              //                       //   //     .manufacturerData,
              //                       //   // )
              //                       // }
              //                       //);
              //                     },
              //                   ),
              //                 ),
              //               );
              //             },
              //           );
              //           //}
              //         } else if (snapshot.hasError) {
              //           log(snapshot.error.toString());
              //           throw ScanException(snapshot.error.toString());
              //         }
              //       } on ScanException catch (e) {
              //         e.showErrorDialog(context, e.toString());
              //       }
              //       return const Text("No exceptions");
              //     },
              //   ));

              //     FutureBuilder<List<BluetoothDevice?>?>(
              //   future: manager.deviceSearch(),
              //   builder: (context, snapshot) {
              //     try {
              //       if (snapshot.hasData) {
              //         log("MyHomePage::TabBarView::FutureBuilder: No error with data. Returning ListView");
              //         return ListView.builder(
              //           itemBuilder: (context, index) {
              //             return SizedBox(
              //               height: 40,
              //               child: Center(
              //                   child:
              //                       Text('Entry ${snapshot.data?[index]}')),
              //             );
              //           },
              //         );
              //       }
              //       if (snapshot.hasError) {
              //         log("MyHomePage::TabBarView::FutureBuilder: Bluetooth data error. No data returned");
              //         throw ScanException(snapshot.error.toString());
              //       } else {
              //         log("MyHomePage::TabBarView::FutureBuilder: Different error. ${snapshot.data.toString()}");
              //         return Column(children: <Widget>[
              //           const SizedBox(
              //             width: 30,
              //             height: 60,
              //           ),
              //           const SizedBox(
              //             width: 60,
              //             height: 60,
              //             child: CircularProgressIndicator(),
              //           ),
              //           Padding(
              //             padding: const EdgeInsets.only(top: 16),
              //             child: Text(
              //                 'Current status ${manager.getStatus().toString()}. Awaiting result...'),
              //           ),
              //         ]);
              //       }
              //     } on ScanException catch (e) {
              //       e.showErrorDialog(context, e.toString());
              //     }
              //     return const Scaffold();
              //   },
              // )

              // log("MyHomePage::Scaffold::TabBarView: No devices found");
              // return const Center(
              //   child: Text("No devices found"),
              // );
              //   } else if (tab.text == "REMOTE") {
              //     return Center(child: Builder(
              //       builder: (context) {
              //         apiServices.addService("Victron");
              //         if (apiServices.getServices?.isNotEmpty ?? true) {
              //           Navigator.pushNamed(context, loginViewRoute);
              //         }
              //         return const Text("Not setup yet.");
              //       },
              //     ));
              //   } else {
              //     return const Text("Error");
              //   }
              // }).toList(),
              ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final list = await manager.deviceSearch();

              log("ListAnswer: ${list?[0]?.deviceId.toString()}");
            },
            tooltip: 'Refresh',
            backgroundColor: const Color.fromARGB(0xFF, 0x3a, 0x26, 0x13),
            foregroundColor: const Color(0xFF9a6432),
            child: const Icon(Icons.refresh),
          ),
        ));
  }

  Future<List<BluetoothDevice>?> deviceSearch() async {
    late List<BluetoothDevice?> devices;
    devices = List.generate(0, <BluetoothDevice>(index) => null);
    return Future?.delayed(
      const Duration(seconds: 5),
      () {
        FutureOr<List<BluetoothDevice>?> answer = Future.value(null);
        devices.add(BluetoothDevice());
        return answer;
      },
    );
  }

  /// Test function
  ///
  /// only to check if there's a reason that Bluetooth scan doesn't work
  void startScan() async {
    BluetoothManager manager = BluetoothManager();

    manager.flutterReactiveBle.scanForDevices(withServices: []);

    if (manager.scanStream != null) {
      manager.deviceSearchStream().listen((device) {
        setState(() {
          bluetoothDevices.add(BluetoothDevice.fromDiscovered(device));
        });
      });
    }

    // for (var key
    //     in manager.flutterReactiveBle.scanRegistry.discoveredDevices.keys) {
    //   bluetoothDevices.add(BluetoothDevice.definedDevice("", key, [], [], []));
    // }
  }

  void changeTitle(BluetoothDevice device) {
    log("changeTitle: Initializing fRB and QC");
    log("changeTitle: Device ${device.deviceId} is also here");
    FlutterReactiveBle flutterReactiveBle = FlutterReactiveBle();
    QualifiedCharacteristic characteristic = QualifiedCharacteristic(
        characteristicId: Uuid.parse("00002a00-0000-1000-8000-00805f9b34fb"),
        serviceId: Uuid.parse(
            "00001800-0000-1000-8000-00805f9b34fb"), //device.services?[0] ?? Uuid([0]),
        deviceId: device.deviceId ?? "");
    List<int>? values;
    log("changeTitle: Going into setState");
    setState(() {
      try {
        flutterReactiveBle.connectToDevice(
            id: device.deviceId ?? "",
            servicesWithCharacteristicsToDiscover: {}).listen((event) {
          if (event.connectionState == DeviceConnectionState.connecting) {
            log("FlutterReactiveBle: Connecting to device...");
          } else if (event.connectionState == DeviceConnectionState.connected) {
            log("changeTitle: Attempting to read characteristic");
            flutterReactiveBle
                .readCharacteristic(characteristic)
                .then((value) => values = value, onError: (error) {
              throw ReadingException(error.toString());
            });
          }
        }, onError: (e) {
          throw ConnectionException(e.errorInfo);
        });
      } on ConnectionException catch (e) {
        e.showErrorDialog(context, e.errorInfo);
      } on ReadingException catch (e) {
        e.showErrorDialog(context, e.errorInfo);
      } catch (e) {
        log("Error: While trying to connect, an error was encoutered: ${e.toString()}");
      }
      log("setState: We tried boys, no success nor exception thrown :(");
      log(characteristic.toString());
    });
    if (values != null) {
      // values is null
    } else {
      // no values yet
    }
  }
}

void sideBar() {}

class SideBarMenu extends StatelessWidget {
  const SideBarMenu({super.key});

  @override
  Widget build(BuildContext context) {
    log("SideBarMenu: building");
    return Scaffold(
      appBar: AppBar(
        title: const Text("Texep Control"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushNamed(homePageRoute);
          },
        ),
      ),
      body: Center(
          child: Column(
        children: [
          TextButton(
            onPressed: () {},
            child: const Text("Devices"),
          ),
          TextButton(
            onPressed: () {},
            child: const Text("Settings"),
          ),
        ],
      )),
    );
  }
}
