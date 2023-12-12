import 'dart:async';

import 'package:app/services/session_service.dart';
import 'package:app/tools/permission_tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:esptouch_flutter/esptouch_flutter.dart';
import 'package:iris_tools/modules/stateManagers/updater_state.dart';

import 'package:app/structures/abstract/state_super.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_sheet.dart';
import 'package:app/tools/app/app_snack.dart';
import 'package:app/tools/app/app_toast.dart';
import 'package:app/tools/route_tools.dart';
import 'package:app/tools/wifi_info_tools.dart';
import 'package:app/views/baseComponents/appbar_builder.dart';
import 'package:app/views/pages/connect_green_mind_page.dart';
import 'package:app/views/states/back_bar.dart';
import 'package:app/views/states/user_guide_box.dart';

/// BSSID is the MAC address.
/// SSID is the technical term for a network name.

class AddGreenMindPage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  AddGreenMindPage({super.key});

  @override
  State createState() => _AddGreenMindPageState();
}

class _AddGreenMindPageState extends StateSuper<AddGreenMindPage> {
  final TextEditingController ssidCtr = TextEditingController();
  final TextEditingController bssidCtr = TextEditingController();
  final TextEditingController passwordCtr = TextEditingController();
  ESPTouchPacket packetState = ESPTouchPacket.broadcast;
  String fetchingWifiInfoState = 'fetchingWifiInfoState';
  String fetchingWifiInfoId = 'fetchingWifiInfoId';
  StreamSubscription<ESPTouchResult>? streamSubscription;
  Timer? timer;
  final List<ESPTouchResult> results = [];
  late ESPTouchTask task;
  bool showGetWifiDataButton = false;

  @override
  void initState(){
    super.initState();

    Future.delayed(const Duration(milliseconds: 800), (){
      onGetWifiInfoClick();
    });
  }

  @override
  void dispose() {
    ssidCtr.dispose();
    bssidCtr.dispose();
    passwordCtr.dispose();
    timer?.cancel();
    streamSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        body: buildBody(),
        resizeToAvoidBottomInset: false,
      ),
    );
  }

  Widget buildBody() {
    return DecoratedBox(
      decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.addWidgetBackG),
            fit: BoxFit.cover,
          )
      ),
      child: Column(
        children: [
          SizedBox(height: 25* hRel),

          CustomAppBar(title: AppMessages.addGreenMind),

          SizedBox(height: 14* hRel),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: UserGuideBox(message: AppMessages.trans('setupGreenMindBySSIDGuide')),
            ),
          ),

          SizedBox(height: 14* hRel),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: UpdaterBuilder(
              id: fetchingWifiInfoId,
              builder: (_,controller, stateData) {
                if(!showGetWifiDataButton){
                  return const SizedBox();
                }

                if(controller.hasState(fetchingWifiInfoState)){
                  return const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(AppDecoration.differentColor),
                  );
                }

                return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppDecoration.differentColor,
                    ),
                    onPressed: onGetWifiInfoClick,
                    child: Text(AppMessages.trans('useCurrentWiFiInfo'))
                );
              },
            ),
          ),

          SizedBox(height: 14* hRel),

          Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 20 * wRel),
                children: [
                  TextField(
                    controller: ssidCtr,
                    enabled: false,
                    style: const TextStyle(color: Colors.white),
                    decoration: AppDecoration.getFilledInputDecoration().copyWith(
                      hintText: 'SSID (wifi router\'s name)',
                      fillColor: Colors.grey.shade400,
                    ),
                  ),

                  /*SizedBox(height: 6* hRel),
                  TextField(
                    controller: bssidCtr,
                    decoration: AppDecoration.getFilledInputDecoration().copyWith(
                      hintText: 'BSSID (MAC address) : 00:a0:c9:14:c8:29',
                    ),
                  ),*/

                  SizedBox(height: 6* hRel),

                  TextField(
                    controller: passwordCtr,
                    decoration: AppDecoration.getFilledInputDecoration().copyWith(
                      hintText: 'Password',
                    ),
                  ),

                  SizedBox(height: 25 * hRel),

                  SizedBox(
                    width: 140 * wRel,
                    child: ElevatedButton(
                      onPressed: onGoClick,
                      child: Text(context.tC('go')!),
                    ),
                  ),

                  SizedBox(height: 3 * hRel),
                  TextButton(
                      onPressed: gotoConnectGreenMindPage,
                      child: Text(AppMessages.trans('IHaveAlreadySetupGreenMind'))
                          .underLine().clickableColor()
                  ),
                ],
              )
          ),

          SizedBox(height: 10 * hRel),
          const BackBar(),
        ],
      ),
    );
  }

  void onGetWifiInfoClick() async {
    final ctr = UpdaterController.forId(fetchingWifiInfoId);
    ctr!.addStateAndUpdate(fetchingWifiInfoState);

    await PermissionTools.requestWifiPermission();
    await PermissionTools.requestLocationPermission();

    try {
      var temp = await WifiInfoTools.ssid ?? '';
      if(temp.startsWith('"')){
        temp = temp.substring(1);
      }

      if(temp.endsWith('"')){
        temp = temp.substring(0, temp.length -1);
      }

      ssidCtr.text = temp;
      bssidCtr.text = await WifiInfoTools.bssid ?? '';
    }
    finally {
      if(ssidCtr.text.isEmpty){
        showGetWifiDataButton = true;
        Future.delayed(const Duration(milliseconds: 200), (){
          AppSheet.showSheetOk(context, AppMessages.trans('pleaseConnectToWifi'));
        });
      }
      else {
        showGetWifiDataButton = false;
      }

      ctr.removeState(fetchingWifiInfoState);
      ctr.update(delay: const Duration(milliseconds: 500));
    }
  }

  Future<void> createTask() async {
    String pass = passwordCtr.text.length.toString().padLeft(2, '0');
    pass += passwordCtr.text;
    pass += SessionService.getLastLoginUserId()?? '';

    task = ESPTouchTask(
      ssid: ssidCtr.text,
      bssid: bssidCtr.text,
      password: pass,
      packet: packetState,
      taskParameter: const ESPTouchTaskParameter(),
    );
  }

  void execute(){
    Stream<ESPTouchResult>? stream = task.execute();
    streamSubscription = stream.listen(results.add);

    final receiving = task.taskParameter.waitUdpReceiving;
    final sending = task.taskParameter.waitUdpSending;
    final cancelLatestAfter = receiving + sending;
    showLoading();

    timer = Timer(cancelLatestAfter, afterExecute);
  }

  void afterExecute() async {
    streamSubscription?.cancel();
    await hideLoading();

    if (mounted) {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            //title: Text('${results.length} device(s) found'),
            title: Text(AppMessages.espDeviceFound(results.length)),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context)..pop(),
                child: Text(AppMessages.ok),
              ),
            ],
          );
        },
      );
      
      if(results.isNotEmpty){

      }
    }
  }

  void gotoConnectGreenMindPage(){
    RouteTools.pushReplacePage(context, ConnectGreenMindPage());
  }

  void Function() copyValue(BuildContext context, String label, String value) {
    return (){
      Clipboard.setData(ClipboardData(text: value));

      AppToast.showToast(context, 'Copied $label to clipboard');
    };
  }

  void onGoClick() async {
    if(ssidCtr.text.isEmpty){
      AppSnack.showError(context, AppMessages.trans('enterSsid'));
      return;
    }

    await createTask();
    execute();
  }
}


/*
Widget resultList(BuildContext context) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (_, index) {
        final result = results[index];

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              GestureDetector(
                onLongPress: copyValue(context, 'BSSID', result.bssid),
                child: Row(
                  children: <Widget>[
                    const Text('BSSID: '),
                    Text(result.bssid,
                        style: const TextStyle(fontFamily: 'monospace')),
                  ],
                ),
              ),

              GestureDetector(
                onLongPress: copyValue(context, 'IP', result.ip),
                child: Row(
                  children: <Widget>[
                    const Text('IP: '),
                    Text(result.ip, style: const TextStyle(fontFamily: 'monospace')),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
*/
