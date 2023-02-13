import 'dart:async';
import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:texepcontrol/constansts/routes.dart';
import 'package:texepcontrol/logic/bluetooth_device.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
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
  late List<BluetoothDevice> bluetoothDevices;

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
          if (bluetoothDevices.isEmpty) {
            return const Center(
              child: Text("No devices"),
            );
          } else {
            final TabController controller = DefaultTabController.of(context);
            controller.addListener(<Widget>() {
              if (!controller.indexIsChanging) {
                return const Center(
                  child: Text("Index is not changing."),
                );
              }
            });
          }
          return const Center();
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Refresh',
        backgroundColor: const Color.fromARGB(0xFF, 0x3a, 0x26, 0x13),
        foregroundColor: const Color(0xFF3a2613),
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Future<List<BluetoothDevice>?> deviceSearch() async {
    late List<BluetoothDevice?> devices;
    devices = List.generate(0, <BluetoothDevice>(index) => null);
    return Future?.delayed(
      const Duration(seconds: 5),
      () {
        FutureOr<List<BluetoothDevice>?> answer = Future.value(null);
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
