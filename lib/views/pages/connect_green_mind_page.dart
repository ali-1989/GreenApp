// Usually, I would prefer splitting up an app into smaller files, but as this
// is an example app for a published plugin, it's better to have everything in
// one file so that all of the examples are visible on https://pub.dev/packages/esptouch_flutter/example


import 'package:flutter/material.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:iris_tools/modules/stateManagers/updater_state.dart';

import 'package:app/managers/green_mind_manager.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_dialog_iris.dart';
import 'package:app/tools/app/app_icons.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_sheet.dart';
import 'package:app/tools/app/app_snack.dart';
import 'package:app/tools/device_info_tools.dart';
import 'package:app/tools/route_tools.dart';
import 'package:app/views/baseComponents/appbar_builder.dart';
import 'package:app/views/states/back_bar.dart';
import 'package:app/views/states/user_guide_box.dart';

/// BSSID is the MAC address.
/// SSID is the technical term for a network name.

class ConnectGreenMindPage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  ConnectGreenMindPage({super.key});

  @override
  State createState() => _ConnectGreenMindPageState();
}

class _ConnectGreenMindPageState extends StateSuper<ConnectGreenMindPage> {
  Requester requester = Requester();
  bool mustShowRetryButton = false;
  String retryUpdaterId = 'retryUpdaterId';

  @override
  void initState(){
    super.initState();

    requestFindGreenMind();
  }

  @override
  void dispose() {
    requester.dispose();

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

          CustomAppBar(title: AppMessages.trans('findGreenMind')),

          SizedBox(height: 14* hRel),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: UserGuideBox(message: AppMessages.trans('pleaseWaitForGreenMind')),
            ),
          ),

          SizedBox(height: 20* hRel),
          UpdaterBuilder(
            id: retryUpdaterId,
            builder: (_, ctr, data) {
              if(mustShowRetryButton){
                return ElevatedButton.icon(
                    onPressed: onRetryAgainClick,
                    label: Text(AppMessages.trans('tryAgain')),
                  icon: const Icon(AppIcons.refresh),
                );
              }

              return const SpinKitThreeInOut(
                delay: Duration(milliseconds: 300),
                color: AppDecoration.secondColor,
              );
            }
          ),
          SizedBox(height: 20* hRel),

          Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 20 * wRel),
                children: [

                  SizedBox(height: 6* hRel),


                  SizedBox(
                    width: 140 * wRel,
                    child: ElevatedButton(
                      onPressed: null,
                      child: Text(context.tC('go')!),
                    ),
                  ),
                ],
              )
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
          requestLinkGreenMind(gm);
        }
    );
  }

  void requestFindGreenMind() async {
    requester.httpRequestEvents.onNetworkError = (req) async {
      AppSnack.showError(context, AppMessages.errorCommunicatingServer);
      mustShowRetryButton = false;
      UpdaterController.forId(retryUpdaterId)?.update();
    };

    requester.httpRequestEvents.onFailState = (req, res) async {
      AppSnack.showError(context, AppMessages.dataNotFound);
      mustShowRetryButton = false;
      UpdaterController.forId(retryUpdaterId)?.update();
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      mustShowRetryButton = false;
      UpdaterController.forId(retryUpdaterId)?.update();

      List list = data[Keys.data];

      if(list.length == 1){
        showAddDialog(list.first);
      }
      else {

      }
    };

    requester.methodType = MethodType.post;
    requester.bodyJson = {};
    requester.bodyJson!['request'] = 'find_my_green_mind';
    requester.bodyJson!['app_id'] = await DeviceInfoTools.getDeviceId();

    requester.prepareUrl();
    requester.request();
  }

  void requestLinkGreenMind(Map gm) async {
    requester.httpRequestEvents.onNetworkError = (req) async {
      AppSheet.showSheetYesNo(context,
          Text(AppMessages.errorCommunicatingServer),
        (){requestLinkGreenMind(gm);},
          null,
        posBtnText: AppMessages.tryAgain,
        negBtnText: AppMessages.cancel
      );
    };

    requester.httpRequestEvents.onFailState = (req, res) async {
      AppSnack.showError(context, AppMessages.operationFailedTryAgain);
      mustShowRetryButton = true;
      UpdaterController.forId(retryUpdaterId)?.update();
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      GreenMindManager.addGreenMind(gm);
    };

    final map = <String, dynamic>{};
    map['request'] = 'link_my_green_mind';
    map['sn'] = gm['serial_number'];
    map['user'] = 101;//SessionService.getLastLoginUser()?.userId;

    requester.bodyJson = map;

    requester.prepareUrl();
    requester.request();
  }

  void onRetryAgainClick() {
    mustShowRetryButton = false;
    UpdaterController.forId(retryUpdaterId)?.update();
    requestFindGreenMind();
  }
}
