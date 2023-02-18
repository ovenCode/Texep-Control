import 'dart:async';
import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:texepcontrol/constants/colors.dart';
import 'package:texepcontrol/constants/routes.dart';
import 'package:texepcontrol/logic/bluetooth_device.dart';
import 'package:texepcontrol/logic/bluetooth_exceptions.dart';
import 'package:texepcontrol/logic/bluetooth_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: ColorsExt.brown500Swatch,
    ),
    home: const MyHomePage(title: 'Texep Control'),
    routes: {
      homePageRoute: (context) => const MyHomePage(title: 'Texep Control'),
      sideBarRoute: (context) => const SideBarMenu(),
    },
  ));
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  void _incrementCounter() {
    setState(() {});
  }

  static const List<Tab> myTabs = <Tab>[
    Tab(text: 'LOCAL'),
    Tab(text: 'REMOTE'),
  ];

  late TabController _tabController;
  late List<BluetoothDevice>? bluetoothDevices;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: myTabs.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
    log("MyHomePage: Building HomePage");

    BluetoothManager manager = BluetoothManager();

    try {
      log("MyHomePage::1stTryCatch: Trying to get devices");
      Future<List<BluetoothDevice?>?> getDevices =
          Future(() async => manager.deviceSearch());
      getDevices.then(
          (value) => {
                Scaffold(
                  appBar: AppBar(),
                  body: Center(
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        return SizedBox(
                          height: 40,
                          child: Center(
                            child: Text("Entry ${value?[index]}"),
                          ),
                        );
                      },
                    ),
                  ),
                )
              }, onError: (e) {
        throw ScanException(e);
      });
    } on ScanException catch (e) {
      e.showErrorDialog(context, e.toString());
    }
    return DefaultTabController(
        length: myTabs.length,
        child: Builder(
          builder: (context) {
            final TabController controller = DefaultTabController.of(context);
            controller.addListener(<Widget>() {
              if (!controller.indexIsChanging) {
                log("MyHomePage::TabController: Index is not changing");
              }
            });

            return Scaffold(
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
              body: TabBarView(
                controller: _tabController,
                children: myTabs.map((Tab tab) {
                  log("MyHomePage::TabBarView: Entered TabBarView. Trying to get devices");

                  return Center(
                      child: FutureBuilder(
                    future: manager.deviceSearch(),
                    builder: (context, snapshot) {
                      try {
                        if (snapshot.hasData) {
                          log("MyHomePage::TabBarView::FutureBuilder: No error with data. Returning ListView");
                          return ListView.builder(
                            itemBuilder: (context, index) {
                              return SizedBox(
                                height: 40,
                                child: Center(
                                    child:
                                        Text('Entry ${snapshot.data?[index]}')),
                              );
                            },
                          );
                        }
                        if (snapshot.hasError) {
                          log("MyHomePage::TabBarView::FutureBuilder: Bluetooth data error. No data returned");
                          return const Center(
                            child: Text("No devices found"),
                          );
                        }
                      } on ScanException catch (e) {
                        e.showErrorDialog(context, e.toString());
                      }
                      return const Text("No data or errors found");
                    },
                  ));

                  // log("MyHomePage::Scaffold::TabBarView: No devices found");
                  // return const Center(
                  //   child: Text("No devices found"),
                  // );
                }).toList(),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: _incrementCounter,
                tooltip: 'Refresh',
                backgroundColor: const Color.fromARGB(0xFF, 0x3a, 0x26, 0x13),
                foregroundColor: const Color(0xFF9a6432),
                child: const Icon(Icons.refresh),
              ),
            );
          },
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
            Navigator.of(context)
                .pushNamedAndRemoveUntil(homePageRoute, (route) => false);
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
