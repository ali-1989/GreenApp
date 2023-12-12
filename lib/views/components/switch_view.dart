import 'package:app/managers/client_data_manager.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/enums/app_events.dart';
import 'package:app/structures/enums/updater_group.dart';
import 'package:app/structures/models/client_data_model.dart';
import 'package:app/structures/models/green_client_model.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_icons.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_tools/modules/stateManagers/updater_state.dart';
import 'package:iris_tools/widgets/custom_card.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';

typedef OnSettingsClick = void Function(BuildContext context, GreenClientModel model);
///------------------------------------------------------
class SwitchView extends StatefulWidget {
  final GreenClientModel clientModel;
  final OnSettingsClick? onSettingsClick;

  // ignore: prefer_const_constructors_in_immutables
  SwitchView({
    super.key,
    required this.clientModel,
    this.onSettingsClick,
  });

  @override
  State createState() => _SwitchViewState();
}
///=============================================================================
class _SwitchViewState extends StateSuper<SwitchView> {
  ClientDataModel? lastDataModel;

  @override
  void initState(){
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      prepareLastModel();
      UpdaterController.addGroupListener([UpdaterGroup.greenClientUpdate], onNewDataListener);
      EventNotifierService.addListener(AppEvents.networkConnected, onReConnectNet);
      requestNewData();
    });
  }

  @override
  void dispose(){
    UpdaterController.removeGroupListener(onNewDataListener);
    EventNotifierService.removeListener(AppEvents.networkConnected, onReConnectNet);

    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: CustomCard(
          color: Colors.black,
          radius: 30,
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Builder(builder: (_){
                      if(lastDataModel == null){
                        return const Center(
                          child: SizedBox(
                            width: 35,
                            height: 35,
                            child: FittedBox(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      }

                      return SizedBox(
                        key: ValueKey(lastDataModel!.isVolumeActive()),
                        height: 40,
                        child: LiteRollingSwitch(
                          value: lastDataModel!.isVolumeActive(),
                          width: 90,
                          textOn: 'on',
                          textOff: 'off',
                          colorOn: Colors.greenAccent[700]!,
                          colorOff: Colors.redAccent[700]!,
                          iconOn: Icons.lightbulb_outline,
                          iconOff: Icons.power_settings_new,
                          textSize: AppDecoration.fontSizeAddRatio(3),
                          onChanged: (bool state) {
                            if(state){
                              lastDataModel!.data = '1';
                            }
                            else {
                              lastDataModel!.data = '0';
                            }

                            sendSwitchState(state);
                          },
                          onTap: (){},
                          onDoubleTap: (){},
                          onSwipe: (){},
                        ),
                      );
                    }),

                    /// settings icon
                    const SizedBox(width: 10),
                    Builder(
                        builder: (context) {
                          return GestureDetector(
                              onTap: () => onSettingsIconClick( context),
                              child: const Icon(AppIcons.settings, color: Colors.white, size: 20)
                          );
                        }
                    )
                  ],
                ),

                const SizedBox(height: 10),

                /// name
                Text(widget.clientModel.getCaption())
                    .color(Colors.blue).bold().fsRRatio(2),

                /// time
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time_filled_outlined, color: Colors.white, size: 18),

                    const SizedBox(width: 4),

                    Builder(
                        builder: (_){
                          if(lastDataModel == null){
                            return const Text('-');
                          }

                          return Text(lastDataModel!.lastConnectionTime())
                              .color(Colors.white);
                        }
                    ),

                    /*FutureBuilder(
                        future: widget.clientModel.lastConnectionTime(),
                        builder: (_, snap){
                          if(snap.data == null || snap.hasError){
                            return const SizedBox();
                          }

                          return Text(snap.data!)
                              .color(Colors.white);
                        }
                    ),*/
                  ],
                )
              ]
          )
      ),
    );
  }

  void onSettingsIconClick(BuildContext ctx) {
    widget.onSettingsClick?.call(ctx, widget.clientModel);
  }

  void onNewDataListener(UpdaterGroupId p1) {
    prepareLastModel();
  }

  void prepareLastModel() async {
    final last = await ClientDataManager.fetchLastData(widget.clientModel.id, false);

    if(last is ClientDataModel){
      lastDataModel = last;
      callState();
    }
  }

  void requestNewData(){
    ClientDataManager.requestNewDataFor(widget.clientModel.id);
  }

  void onReConnectNet({data}) {
    requestNewData();
  }

  void sendSwitchState(bool state) async {
    final x = await ClientDataManager.requestChangeSwitch(lastDataModel!, state);
print('xxxxxxxx $x');
    if(!x){
      if(lastDataModel!.isVolumeActive()) {
        lastDataModel!.data = '0';
      }
      else {
        lastDataModel!.data = '1';
      }

      callState();

      if(mounted){
        AppSnack.showError(context, AppMessages.errorCommunicatingServer);
      }
    }
  }
}
