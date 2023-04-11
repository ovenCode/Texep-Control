import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:texepcontrol/constants/colors.dart';
import 'package:texepcontrol/logic/api_services.dart';
import 'package:texepcontrol/main.dart';
import 'package:texepcontrol/utils/radial_indicator/radial_indicator.dart';

/// View that intends to show more information about a given site
///
/// Here the user will see devices used in the installation
class SiteView extends StatefulWidget {
  final String _siteName, _siteId;
  final ApiServices _apiServices;

  const SiteView({super.key, required apiServices, siteId, required siteName})
      : _apiServices = apiServices,
        _siteId = siteId,
        _siteName = siteName;

  @override
  State<SiteView> createState() => _SiteViewState();
}

class _SiteViewState extends State<SiteView> {
  String _siteName = "", _siteId = "", voltage = "no value", state = "  ";
  ApiServices _apiServices = ApiServices();
  int i = 0;

  @override
  void initState() {
    // TODO: implement initState
    _apiServices = widget._apiServices;
    _siteId = widget._siteId;
    _siteName = widget._siteName;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(
      Duration.zero,
      () async {
        await _apiServices.getServices[0].requestSiteDevices(_siteId);
      },
    );

    log("SiteView::build: Building sites view");
    return Scaffold(
      appBar: AppBar(
        title: Text(_siteName),
      ),
      body: Center(
        child: FutureBuilder(
          future: (_apiServices.getServices[0]).requestSiteDevices(_siteId),
          builder: (context, snapshot) {
            switch (snapshot.data) {
              case "Success":
                log("SiteView::build::FutureBuilder: Snapshot info: ${snapshot.data}");
                return FutureBuilder(
                  future:
                      (_apiServices.getServices[0].requestSiteStats(_siteId)),
                  builder: (context, snap) {
                    switch (snap.data) {
                      case "Success":
                        return ListView.builder(
                            itemCount: (_apiServices.getServices[0])
                                .getDeviceNames
                                .length,
                            itemBuilder: (context, index) {
                              switch (index) {
                                case 0:
                                  return SizedBox(
                                    height: 150,
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 10, 0, 8),
                                            child: Text(
                                                (_apiServices.getServices[0])
                                                    .getDeviceNames[
                                                        "productName$index"]
                                                    .toString()),
                                          ),
                                          const Divider(),
                                          FutureBuilder(
                                              future: (_apiServices
                                                      .getServices[0])
                                                  .requestData(
                                                      "System Overview summary"),
                                              builder: (context, snapshot) {
                                                switch (snapshot.data
                                                    ?.substring(0, 7)) {
                                                  case "Success":
                                                    return Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            const Text(
                                                                "Installation status: "),
                                                            Text(_apiServices
                                                                .getServices[0]
                                                                .getResponse(
                                                                    "VE.Bus State")
                                                                .toString()),
                                                          ],
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            const Text(
                                                                "Battery voltage: "),
                                                            Text(
                                                                "${_apiServices.getServices[0].getResponse("Battery Voltage").toString()} V"),
                                                          ],
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            const Text(
                                                                "Battery current: "),
                                                            Text(
                                                                "${_apiServices.getServices[0].getResponse("Battery Current").toString()} A"),
                                                          ],
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            const Text(
                                                                "Input voltage(1): "),
                                                            Text(
                                                                "${_apiServices.getServices[0].getResponse("Input Voltage Phase 1").toString()} V"),
                                                          ],
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            const Text(
                                                                "Output voltage(1): "),
                                                            Text(
                                                                "${_apiServices.getServices[0].getResponse("Output Voltage Phase 1").toString()} V"),
                                                          ],
                                                        )
                                                      ],
                                                    );
                                                  case "Error r":
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          AlertDialog(
                                                        title:
                                                            const Text("Error"),
                                                        content: Text(
                                                            "An error has occured in requestData: ${snapshot.data}"),
                                                      ),
                                                    );
                                                    return const Text("Error");
                                                  default:
                                                    return const Text(
                                                        "loading...");
                                                }
                                              }),
                                        ],
                                      ),
                                    ),
                                  );
                                case 1:
                                  return Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: FutureBuilder(
                                      future: apiServices.getServices[0]
                                          .requestData("Diagnostic data"),
                                      builder: (context, snapshot) {
                                        switch (
                                            snapshot.data?.substring(0, 7)) {
                                          case "Success":
                                            return SizedBox(
                                              height: 350,
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "Battery power: ${apiServices.getServices[0].getResponse("Diagnostic data")["0 bp"]["formattedValue"].toString()}",
                                                    ),
                                                    Text(
                                                      " System state: ${apiServices.getServices[0].getResponse("Diagnostic data")["0 ss"]["formattedValue"].toString()}",
                                                    ),
                                                    Text(
                                                      " Power input: ${apiServices.getServices[0].getResponse("Diagnostic data")["0 a1"]["formattedValue"].toString()}",
                                                    ),
                                                    Text(
                                                      " State of charge: ${apiServices.getServices[0].getResponse("Diagnostic data")["0 bs"]["formattedValue"].toString()}",
                                                    ),
                                                    Text(
                                                      " State of charge: ${apiServices.getServices[0].getResponse("Diagnostic data")["0 PVP"]["formattedValue"] ?? ""}",
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          default:
                                            return const Text("No values");
                                        }
                                      },
                                    ),
                                  );
                                case 2:
                                  return FutureBuilder(
                                      future: _apiServices.getServices[0]
                                          .requestData("Diagnostic data"),
                                      builder: (context, snapshot) {
                                        switch (snapshot.data) {
                                          case "Success":
                                            state = _apiServices.getServices[0]
                                                .getResponse("Diagnostic data")[
                                                    "0 bs"]["formattedValue"]
                                                .toString();
                                            break;
                                          default:
                                        }

                                        return RadialIndicator(
                                          height: 200,
                                          width: 200,
                                          start: 135.0,
                                          end: 270.0 *
                                              (double.tryParse(state.substring(
                                                      0, state.length - 2)) ??
                                                  0) /
                                              100.0,
                                          primaryColor: ColorsExt.brown100,
                                          secondaryColor: Colors.white,
                                          text: state,
                                        );
                                      });
                                case 3:
                                  return Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 8, 0, 10),
                                    child: FutureBuilder(
                                        future: null,
                                        builder: (context, snapshot) {
                                          return SizedBox(
                                            height: 80,
                                            child: Center(
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(0, 0, 0, 8.0),
                                                    child: Text((_apiServices
                                                            .getServices[0])
                                                        .getDeviceNames[
                                                            "productName$index"]
                                                        .toString()),
                                                  ),
                                                  Text(
                                                      "Power: ${_apiServices.getServices[0].getResponse("Diagnostic data") != null ? _apiServices.getServices[0].getResponse("Diagnostic data")["0 ScW"]["formattedValue"] : ""}")
                                                ],
                                              ),
                                            ),
                                          );
                                        }),
                                  );
                                case 4:
                                  return Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 8, 0, 10),
                                    child: SizedBox(
                                      height: 80,
                                      child: Center(
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 0, 0, 8.0),
                                              child: Text(
                                                  (_apiServices.getServices[0])
                                                      .getDeviceNames[
                                                          "productName$index"]
                                                      .toString()),
                                            ),
                                            Text(
                                                "Power: ${_apiServices.getServices[0].getResponse("Diagnostic data") != null ? _apiServices.getServices[0].getResponse("Diagnostic data")["1 ScW"]["formattedValue"] : ""}")
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                case 5:
                                  return Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 8, 0, 10),
                                    child: SizedBox(
                                      height: 80,
                                      child: Center(
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 0, 0, 8.0),
                                              child: Text(
                                                  (_apiServices.getServices[0])
                                                      .getDeviceNames[
                                                          "productName$index"]
                                                      .toString()),
                                            ),
                                            Text(
                                                "Power: ${_apiServices.getServices[0].getResponse("Diagnostic data") != null ? _apiServices.getServices[0].getResponse("Diagnostic data")["2 ScW"]["formattedValue"] : ""}")
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                default:
                                  return Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 8, 0, 10),
                                    child: SizedBox(
                                      height: 80,
                                      child: Center(
                                        child: Column(
                                          children: [
                                            Text((_apiServices.getServices[0])
                                                .getDeviceNames[
                                                    "productName$index"]
                                                .toString())
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                              }
                            });
                      case "Error":
                        return AlertDialog(
                          title: const Text("Error"),
                          content: Text(snap.error.toString()),
                        );
                      case null:
                        return const Center(
                          child: Text("Null"),
                        );
                      default:
                        log("SiteView::build::FutureBuilder: Snapshot info: ${snap.data}");
                        return Center(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(
                                  value: null,
                                  strokeWidth: 7.0,
                                  backgroundColor: ColorsExt.brown100,
                                  color: ColorsExt.brown500,
                                  semanticsLabel: "Waiting...",
                                ),
                                Text("Waiting... ${snap.data.toString()}")
                              ]),
                        );
                    }
                  },
                );
              case "Error":
                return const AlertDialog(
                  title: Text("Error"),
                  content: Text("Some error"),
                );

              default:
                log("SiteView::build::FutureBuilder: Snapshot info: ${snapshot.data}");
                return Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          value: null,
                          strokeWidth: 7.0,
                          backgroundColor: ColorsExt.brown100,
                          color: ColorsExt.brown500,
                          semanticsLabel: "Waiting...",
                        ),
                        Text("Waiting... ${snapshot.data.toString()}")
                      ]),
                );
            }
          },
        ),
      ),
    );
  }
}
