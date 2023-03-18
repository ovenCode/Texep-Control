import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:texepcontrol/constants/colors.dart';
import 'package:texepcontrol/logic/api_services.dart';

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
  String _siteName = "", _siteId = "";
  ApiServices _apiServices = ApiServices();

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
    // TODO: fill Listview

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
                          itemBuilder: (context, index) => SizedBox(
                            height: 65,
                            child: Center(
                              child: Column(
                                children: [
                                  Text((_apiServices.getServices[0])
                                      .getDeviceNames["productName$index"]
                                      .toString()),
                                  Text((_apiServices.getServices[0])
                                      .getDeviceStats
                                      .toString())
                                ],
                              ),
                            ),
                          ),
                        );
                      default:
                        log("SiteView::build::FutureBuilder: Snapshot info: ${snapshot.data}");
                        return const Center(
                          child: CircularProgressIndicator(
                            value: null,
                            strokeWidth: 7.0,
                            backgroundColor: ColorsExt.brown100,
                            color: ColorsExt.brown500,
                            semanticsLabel: "Waiting...",
                          ),
                        );
                    }
                  },
                );

              default:
                log("SiteView::build::FutureBuilder: Snapshot info: ${snapshot.data}");
                return const Center(
                  child: CircularProgressIndicator(
                    value: null,
                    strokeWidth: 7.0,
                    backgroundColor: ColorsExt.brown100,
                    color: ColorsExt.brown500,
                    semanticsLabel: "Waiting...",
                  ),
                );
            }
          },
        ),
      ),
    );
  }
}
