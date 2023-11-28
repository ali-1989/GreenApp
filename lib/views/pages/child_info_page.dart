// one file so that all of the examples are visible on https://pub.dev/packages/esptouch_flutter/example


import 'package:app/managers/green_client_manager.dart';
import 'package:app/structures/enums/client_type.dart';
import 'package:app/structures/enums/updater_group.dart';
import 'package:app/structures/models/green_child_model.dart';
import 'package:app/structures/models/green_client_model.dart';
import 'package:app/structures/models/green_mind_model.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_icons.dart';
import 'package:app/tools/date_tools.dart';
import 'package:app/tools/route_tools.dart';
import 'package:app/views/pages/rename_green_child.dart';
import 'package:flutter/material.dart';


import 'package:app/structures/abstract/state_super.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/views/baseComponents/appbar_builder.dart';
import 'package:iris_tools/modules/stateManagers/updater_state.dart';
import 'package:iris_tools/widgets/custom_card.dart';
import 'package:iris_tools/widgets/icon/circular_icon.dart';
import 'package:iris_tools/widgets/text/custom_rich.dart';

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

  @override
  void initState() {
    super.initState();

    greenChild = widget.greenChild;
    prepareList();
    GreenClientManager.requestClientsFor(greenChild);
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

          SizedBox(height: 30 * hRel),

          //buildDetail(),
          //buildSwitches(),
          Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                itemCount: itemList.length + 1 + (getSwitches().isEmpty? 0: 1),
                  itemBuilder: itemBuilder
              )
          )
        ],
      ),
    );
  }

  Widget buildDetail(){
    return CustomCard(
        color: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Detail').color(Colors.white).bold(),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
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

            /// name
            SizedBox(height: 2 * hRel),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: onRenameClick,
              child: Row(
                children: [
                  CustomRich(
                      children: [
                        Text('name: ', style: keyStyle),
                        Text(greenChild.getCaption(), style: valueStyle),
                      ]
                  ),

                  const SizedBox(width: 10),

                  GestureDetector(
                    onTap: onRenameClick,
                    child: const CircularIcon(
                      icon: AppIcons.edit,
                      itemColor: Colors.white,
                      backColor: AppDecoration.differentColor,
                      size: 24,
                    ),
                  )
                ],
              ),
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
        )
    );
  }

  Widget buildSwitches(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: .0, vertical: 20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomCard(
              color: Colors.black,
              radius: 30,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomRich(
                      children: [
                        const Text('Sights')
                            .color(Colors.blue).bold().fsRRatio(2),

                        const Text(' And ')
                            .color(Colors.white),

                        const Text('Guides')
                            .color(Colors.pinkAccent).bold().fsRRatio(2)
                      ]
                  )
                ],
              )
          ),

        ],
      ),
    );
  }

  Widget? itemBuilder(BuildContext context, int index) {
    if(index == 0){
      return buildDetail();
    }

    if(index == 1 && getSwitches().isNotEmpty){
      return buildSwitches();
    }

   final itm = itemList[index- (getSwitches().isNotEmpty? 2:1)];

    return buildSightGuideRow(itm);
  }

  Widget buildSightGuideRow(GreenClientModel itm) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: CustomCard(
        color: Colors.grey.shade800,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Row(
                  children: [
                    Text(itm.getCaption())
                        .color(Colors.white).bold(),
                  ],
                ),
              ],
            ),
          )
      ),
    );
  }

  void prepareList(){
    itemList.clear();
    itemList.addAll(GreenClientManager.items.where(
            (element) => element.ownerId == greenChild.id
    ));
  }

  List getSwitches(){
    return itemList.where(
            (element) => element.type == ClientType.volume)
        .toList();
  }
  void onRenameClick() {
    RouteTools.pushPage(context, RenameGreenChild(greenChild: greenChild));
  }
}
