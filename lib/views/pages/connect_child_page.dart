// Usually, I would prefer splitting up an app into smaller files, but as this
// is an example app for a published plugin, it's better to have everything in
// one file so that all of the examples are visible on https://pub.dev/packages/esptouch_flutter/example


import 'dart:async';

import 'package:app/managers/green_mind_manager.dart';
import 'package:app/services/websocket_service.dart';
import 'package:app/structures/enums/updater_group.dart';
import 'package:app/structures/models/green_mind_model.dart';
import 'package:app/tools/app/app_sheet.dart';
import 'package:app/tools/app/app_toast.dart';
import 'package:flutter/material.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:iris_tools/modules/stateManagers/updater_state.dart';

import 'package:app/structures/abstract/state_super.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_dialog_iris.dart';
import 'package:app/tools/app/app_icons.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/route_tools.dart';
import 'package:app/views/baseComponents/appbar_builder.dart';
import 'package:app/views/states/back_bar.dart';
import 'package:app/views/states/user_guide_box.dart';

/// BSSID is the MAC address.
/// SSID is the technical term for a network name.

class ConnectChildPage extends StatefulWidget {
  final GreenMindModel greenMind;

  // ignore: prefer_const_constructors_in_immutables
  ConnectChildPage({super.key, required this.greenMind});

  @override
  State createState() => _ConnectChildPageState();
}
///=============================================================================
class _ConnectChildPageState extends StateSuper<ConnectChildPage> {
  bool mustShowRetryButton = false;
  String retryUpdaterId = 'retryUpdaterId';
  int counter = 60;
  int beforeDeviceCount = 0;
  Timer? timer;

  @override
  void initState(){
    super.initState();

    beforeDeviceCount = widget.greenMind.children.length;
    WebsocketService.connect();
    UpdaterController.addGroupListener([UpdaterGroup.greenMindUpdate], onNewDevice);
    startTimer();
    requestForAddDeviceMode();
  }

  @override
  void dispose() {
    timer?.cancel();
    UpdaterController.removeGroupListener(onNewDevice);

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

          CustomAppBar(title: AppMessages.transCap('addNewDeviceToMind')),

          SizedBox(height: 50* hRel),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: UserGuideBox(message: AppMessages.trans('gm254')),
            ),
          ),

          //SizedBox(height: 50* hRel),

          Expanded(
              child: Center(
                child: UpdaterBuilder(
                    id: retryUpdaterId,
                    builder: (_, ctr, data) {
                      if(mustShowRetryButton){
                        return ElevatedButton.icon(
                          onPressed: onRetryAgainClick,
                          label: Text(AppMessages.trans('iWillWaitAgain')),
                          icon: const Icon(AppIcons.refresh),
                        );
                      }

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('$counter').color(Colors.white).bold(),

                          const SizedBox(width: 12),

                          const SpinKitThreeInOut(
                            delay: Duration(milliseconds: 300),
                            color: AppDecoration.secondColor,
                          ),
                        ],
                      );
                    }
                ),
              ),
          ),

          const BackBar(),
        ],
      ),
    );
  }

  void showAddDialog(Map gm){
    AppDialogIris.instance.showYesNoDialog(
        context,
        descView: Column(
          children: [
            Text(AppMessages.trans('deviceFoundAddToYourList'))
                .bold().fsRRatio(2),

            Text('SerialNumber: ${gm['serial_number']}')
          ],
        ),
        yesFn: (_){
          RouteTools.popIfCan(_);
          //requestLinkGreenMind(gm);
        }
    );
  }

  void onRetryAgainClick() {
    mustShowRetryButton = false;
    counter = 60;
    startTimer();

    UpdaterController.forId(retryUpdaterId)?.update();
    GreenMindManager.requestChangeToAddDeviceMode(widget.greenMind.id);
  }

  void startTimer() {
    if(timer == null || !timer!.isActive){
      timer = Timer.periodic(const Duration(seconds: 1), timerFn);
    }
  }

  void timerFn(t) {
    if(counter > 1){
      counter--;
    }
    else {
      mustShowRetryButton = true;
      timer?.cancel();
      timer = null;
      AppToast.showToast(context, context.t('unfortunatelyCommunicationNotEstablished')!);
    }

    UpdaterController.forId(retryUpdaterId)!.update();
  }

  void onNewDevice(UpdaterGroupId p1) {
    final newCount = widget.greenMind.children.length;

    if(newCount <= beforeDeviceCount){
      return;
    }

    UpdaterController.removeGroupListener(onNewDevice);

    AppSheet.showSheetOneAction(
        context,
        AppMessages.trans('congratulationForNewGreenChild'),
      onButton: (){
          RouteTools.popIfCan(context);
      }
    );
  }

  void requestForAddDeviceMode() {
    GreenMindManager.requestChangeToAddDeviceMode(widget.greenMind.id);
  }
}
