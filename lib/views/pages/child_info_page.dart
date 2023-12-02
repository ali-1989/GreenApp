import 'dart:ui';

import 'package:app/managers/client_data_manager.dart';
import 'package:app/managers/green_client_manager.dart';
import 'package:app/structures/enums/client_type.dart';
import 'package:app/structures/enums/updater_group.dart';
import 'package:app/structures/models/green_child_model.dart';
import 'package:app/structures/models/green_client_model.dart';
import 'package:app/structures/models/green_mind_model.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_icons.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_pop.dart';
import 'package:app/tools/app/app_sheet.dart';
import 'package:app/tools/date_tools.dart';
import 'package:app/tools/route_tools.dart';
import 'package:app/views/components/live_and_chart_view.dart';
import 'package:app/views/pages/rename_client_page.dart';
import 'package:app/views/pages/rename_green_child.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';


import 'package:app/structures/abstract/state_super.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/views/baseComponents/appbar_builder.dart';
import 'package:iris_tools/modules/stateManagers/updater_state.dart';
import 'package:iris_tools/widgets/custom_card.dart';
import 'package:iris_tools/widgets/icon/circular_icon.dart';
import 'package:iris_tools/widgets/text/custom_rich.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';

class ChildInfoPage extends StatefulWidget {
  final GreenMindModel greenMind;
  final GreenChildModel greenChild;

  // ignore: prefer_const_constructors_in_immutables
  ChildInfoPage({super.key, required this.greenMind, required this.greenChild});

  @override
  State createState() => _ChildInfoPageState();
}
///=============================================================================
class _ChildInfoPageState extends StateSuper<ChildInfoPage> {
  late GreenChildModel greenChild;
  late TextStyle keyStyle;
  late TextStyle valueStyle;
  List<GreenClientModel> itemList = [];
  var expandCtr = ExpandableController();

  @override
  void initState() {
    super.initState();

    greenChild = widget.greenChild;
    prepareList();
    expandCtr.expanded = itemList.isEmpty;

    GreenClientManager.current!.requestClientsFor(greenChild);
    keyStyle = TextStyle(color: Colors.grey.shade300);
    valueStyle = const TextStyle(color: Colors.white, fontWeight: FontWeight.bold);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: UpdaterBuilder(
        groupIds: const [UpdaterGroup.greenClientUpdate, UpdaterGroup.greenMindUpdate],
        builder: (_, ctr, data) {
         prepareList();
          return Scaffold(
            body: buildBody(),
          );
        }
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
          SizedBox(height: 25 * hRel),

          CustomAppBar(
              titleView: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Text(greenChild.isSight()? 'G-Sight' : 'G-Guide').color(Colors.grey).fsRRatio(-1.5),
                  ),
                  Text(greenChild.getCaption())
                      .color(Colors.white).bold().fsRRatio(1),
                ],
              )
          ),

          SizedBox(height: 20 * hRel),

          buildDetail(),

          /*Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                itemCount: itemList.length,
                  itemBuilder: itemBuilder
              )
          )*/
          Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: CustomScrollView(
                  slivers: [
                    buildSwitches(),
                    buildCharts(),
                  ],
                ),
              ),
          ),
        ],
      ),
    );
  }

  Widget buildDetail(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        children: [
          CustomCard(
            color: Colors.black,
            child: ExpandablePanel(
              controller: expandCtr,
                theme: const ExpandableThemeData(
                  tapHeaderToExpand: false,
                  iconColor: Colors.white,
                ),
                header: Padding(
                  padding: const EdgeInsets.only(top: 10.0, left: 20, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Detail').color(Colors.white).bold(),
                      GestureDetector(
                        onTap: onSettingClick,
                          child: const Icon(AppIcons.settings, color: Colors.white, size: 20,)
                      )
                    ],
                  ),
                ),
                collapsed: const SizedBox(),
                expanded: Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Divider(color: Colors.grey.shade200),
                      ),

                      /// ID
                      Row(
                        children: [
                          Expanded(
                              child: CustomRich(
                                  children: [
                                    Text('ID: ', style: keyStyle),
                                    Text('${greenChild.id}', style: valueStyle),
                                  ]
                              )
                          ),

                          Expanded(
                              child: CustomRich(
                                  children: [
                                    Text('SN: ', style: keyStyle),
                                    Text(greenChild.serialNumber, style: valueStyle),
                                  ]
                              )
                          ),
                        ],
                      ),

                      /// children
                      SizedBox(height: 5 * hRel),
                      Row(
                        children: [
                          CustomRich(
                              children: [
                                Text('client count: ', style: keyStyle),
                                Text('${itemList.length}', style: valueStyle),
                              ]
                          ),
                        ],
                      ),

                      /// version
                      SizedBox(height: 10 * hRel),
                      Row(
                        children: [
                          Expanded(
                              child: CustomRich(
                                  children: [
                                    Text('version of Firmware: ', style: keyStyle),
                                    Text('${greenChild.firmwareVersion}', style: valueStyle),
                                  ]
                              )
                          ),
                        ],
                      ),

                      /// battery
                      SizedBox(height: 10 * hRel),
                      Row(
                        children: [
                          Expanded(
                              child: CustomRich(
                                  children: [
                                    Text('battery: ', style: keyStyle),
                                    Text('${greenChild.batteryLevel?? '-'}', style: valueStyle),
                                  ]
                              )
                          ),
                        ],
                      ),

                      /// register time
                      SizedBox(height: 10 * hRel),
                      Row(
                        children: [
                          Expanded(
                              child: CustomRich(
                                  children: [
                                    Text('added at: ', style: keyStyle),
                                    Text(DateTools.dateOnlyRelative(greenChild.registerDate), style: valueStyle),
                                  ]
                              )
                          ),
                        ],
                      ),

                      /// connection time
                      SizedBox(height: 10 * hRel),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                              child: CustomRich(
                                  children: [
                                    Text('time of last connection: ', style: keyStyle),
                                    Text(greenChild.lastConnectionTime(), style: valueStyle)
                                        .color(greenChild.getStatusColor()),
                                  ]
                              )
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ),

          if(itemList.isEmpty)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10),
              child: Padding(
                padding: const EdgeInsets.only(top: 70),
                child: CustomCard(
                  color: Colors.white.withAlpha(120),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 50),
                    child: Text(AppMessages.transCap('withoutDevice')).bold(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildSwitches(){
    final items = itemList.where(
            (element) => element.isVolume()).toList();

    return SliverGrid.builder(
      itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          mainAxisExtent: 140,
        ),
        itemBuilder: (_, idx){
          return buildSwitch(items[idx]);
        }
    );
  }

  Widget buildSwitch(GreenClientModel itm){
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
                    SizedBox(
                      height: 40,
                      child: LiteRollingSwitch(
                        width: 90,
                        value: true,
                        textOn: 'on',
                        textOff: 'off',
                        colorOn: Colors.greenAccent[700]!,
                        colorOff: Colors.redAccent[700]!,
                        iconOn: Icons.lightbulb_outline,
                        iconOff: Icons.power_settings_new,
                        textSize: 16.0,
                        onChanged: (bool state) {

                        },
                        onTap: (){},
                        onDoubleTap: (){},
                        onSwipe: (){

                        },
                      ),
                    ),

                    const SizedBox(width: 10),
                    Builder(
                      builder: (context) {
                        return GestureDetector(
                          onTap: onSettingOnSwitchClick(itm, context),
                            child: const Icon(AppIcons.settings, color: Colors.white, size: 20)
                        );
                      }
                    )
                  ],
                ),

                const SizedBox(height: 10),

                Text(itm.getCaption())
                    .color(Colors.blue).bold().fsRRatio(2),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time_filled_outlined, color: Colors.white, size: 18),

                    const SizedBox(width: 4),

                    Builder(
                      builder: (context) {
                        final data = ClientDataManager.getVolumeById(itm.id);

                        if(data != null){
                          return Text(data.lastConnectionTime())
                              .color(Colors.white);
                        }

                        return FutureBuilder(
                            future: itm.lastConnectionTime(),
                            builder: (_, snap){
                              if(snap.data == null || snap.hasError){
                                return const SizedBox();
                              }

                              return Text(snap.data!)
                                  .color(Colors.white);
                            }
                        );
                      }
                    ),
                  ],
                )
              ]
          )
      ),
    );
  }

  Widget buildCharts(){
    final items = itemList.where(
            (element) => !element.isVolume()).toList();

    return SliverList.builder(
      itemCount: items.length,
     itemBuilder: (_, idx){
        return LiveAndChartView(clientModel: items[idx]);
     },
    );
  }

  void prepareList(){
    itemList.clear();
    itemList.addAll(GreenClientManager.current!.items.where(
            (element) => element.ownerId == greenChild.id
    ));


    final sortConditions = [
      ClientType.volume,
      ClientType.temperature,
      ClientType.humidity,
      ClientType.light,
      ClientType.soil,
    ];

    int sort(GreenClientModel item1, GreenClientModel item2){
      if(item1.type == item2.type){
        return 0;
      }

      if(sortConditions.indexOf(item1.type) > sortConditions.indexOf(item2.type)) {
        return 1;
      }

      return -1;
    }

    itemList.sort(sort);
  }

  void onSettingClick() {
    List<Widget> widgets = [];

    widgets.add(
      Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: (){
                RouteTools.popIfCan(context);
              },
              child: const CircularIcon(
                icon: AppIcons.close,
              ),
            ),
          ],
        ),
      ),
    );

    widgets.add(
        GestureDetector(
          onTap: (){
            RouteTools.popIfCan(context);
            RouteTools.pushPage(context, RenameGreenChild(greenChild: greenChild));
          },
          child: Row(
            children: [
              const Icon(AppIcons.pencil, color: AppDecoration.secondColor,),
              const SizedBox(width: 10),
              Text(AppMessages.transCap('rename')).bold(),
            ],
          ),
        )
    );

    AppSheet.showSheetMenu(
      context,
      widgets,
      'mind-settings',
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30, top: 8),
    );
  }

  VoidCallback onSettingOnSwitchClick(GreenClientModel itm, BuildContext ctx) {
    return (){
      void rename(){
        RouteTools.pushPage(context, RenameClientPage(clientModel: itm));
      }

      void addToHome(){

      }

      showMenu(
          context: context,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          position: AppPop.findPosition(ctx),
          items: [
            PopupMenuItem(
              height: 30,
                onTap: rename,
                child: Row(
                  children: [
                    const Icon(Icons.drive_file_rename_outline),
                    const SizedBox(width: 20),
                    Text(AppMessages.transCap('rename')).bold(),
                  ],
                )
            ),

            PopupMenuItem(
              height: 30,
                onTap: addToHome,
                child: Row(
                  children: [
                    const Icon(Icons.add),

                    const SizedBox(width: 20),
                    Text(AppMessages.trans('addToHome')).bold(),
                  ],
                )
            ),
          ],
      );
    };
  }

}
