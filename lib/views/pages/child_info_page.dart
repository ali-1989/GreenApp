import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:expandable/expandable.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/modules/stateManagers/updater_state.dart';
import 'package:iris_tools/widgets/custom_card.dart';
import 'package:iris_tools/widgets/icon/circular_icon.dart';
import 'package:iris_tools/widgets/text/custom_rich.dart';

import 'package:app/managers/green_client_manager.dart';
import 'package:app/managers/home_widget_manager.dart';
import 'package:app/services/session_service.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/enums/client_type.dart';
import 'package:app/structures/enums/updater_group.dart';
import 'package:app/structures/models/green_child_model.dart';
import 'package:app/structures/models/green_client_model.dart';
import 'package:app/structures/models/green_mind_model.dart';
import 'package:app/structures/models/home_widget_model.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_icons.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_pop.dart';
import 'package:app/tools/app/app_sheet.dart';
import 'package:app/tools/date_tools.dart';
import 'package:app/tools/route_tools.dart';
import 'package:app/views/baseComponents/appbar_builder.dart';
import 'package:app/views/components/live_and_chart_view.dart';
import 'package:app/views/components/switch_view.dart';
import 'package:app/views/pages/rename_client_page.dart';
import 'package:app/views/pages/rename_green_child.dart';

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
    GreenClientManager.current!.requestClientsFor(greenChild.mindId, greenChild.id);
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
        groupIds: const [UpdaterGroup.greenClientUpdate], // UpdaterGroup.greenMindUpdate
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
          ClipRect(
            clipBehavior: Clip.hardEdge,
            //decoration: const BoxDecoration(),
            child: BackdropFilter(
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
          return SwitchView(
              clientModel: items[idx],
            onSettingsClick: onSettingOnSwitchClick,
          );
        }
    );
  }

  Widget buildCharts(){
    final items = itemList.where(
            (element) => !element.isVolume()).toList();

    return SliverList.builder(
      itemCount: items.length,
     itemBuilder: (_, idx){
        return LiveAndChartView(
            clientModel: items[idx],
          onSettingsClick: onSettingOnSwitchClick,
        );
     },
    );
  }

  void prepareList(){
    final beforeCount = itemList.length;

    itemList.clear();
    itemList.addAll(GreenClientManager.current!.items.where(
            (element) => element.ownerId == greenChild.id
    ));

    if(itemList.isNotEmpty && beforeCount < 1){
      expandCtr.expanded = false;
    }

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

  void onSettingOnSwitchClick(BuildContext ctx, GreenClientModel itm) {
    void rename() async {
      await RouteTools.pushPage(context, RenameClientPage(clientModel: itm));
      callState();
    }

    void addToHome(){
      final hw = HomeWidgetModel();
      hw.userId = SessionService.getLastLoginUserId()!;
      hw.clientId = itm.id;
      hw.greenMindId = widget.greenMind.id;
      hw.childId = itm.ownerId;
      hw.registerDate = DateHelper.nowMinusUtcOffset();
      hw.order = HomeWidgetManager.current!.getLastOrder()+1;

      HomeWidgetManager.current?.addHomeWidget(hw);
    }

    void removeFromHome(){
      HomeWidgetManager.current?.removeWidget(itm.id);
    }

    bool existInHome = HomeWidgetManager.current!.existOnHome(itm.id);
    String keyName = 'addToHome';

    if(existInHome){
      keyName = 'removeFromHome';
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
            onTap: existInHome? removeFromHome: addToHome,
            child: Row(
              children: [
                const Icon(Icons.add),

                const SizedBox(width: 20),
                Text(AppMessages.trans(keyName)).bold(),
              ],
            )
        ),
      ],
    );
  }
}
