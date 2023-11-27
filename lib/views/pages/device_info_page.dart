// one file so that all of the examples are visible on https://pub.dev/packages/esptouch_flutter/example


import 'package:app/structures/enums/updater_group.dart';
import 'package:app/structures/models/green_child_model.dart';
import 'package:app/structures/models/green_mind_model.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_dialog_iris.dart';
import 'package:app/tools/app/app_icons.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/date_tools.dart';
import 'package:app/tools/route_tools.dart';
import 'package:app/views/pages/child_info_page.dart';
import 'package:app/views/pages/connect_child_page.dart';
import 'package:flutter/material.dart';


import 'package:app/structures/abstract/state_super.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/views/baseComponents/appbar_builder.dart';
import 'package:iris_tools/modules/stateManagers/updater_state.dart';
import 'package:iris_tools/widgets/circle.dart';
import 'package:iris_tools/widgets/custom_card.dart';
import 'package:iris_tools/widgets/icon/circular_icon.dart';
import 'package:iris_tools/widgets/text/custom_rich.dart';

/// BSSID is the MAC address.
/// SSID is the technical term for a network name.

class DeviceInfoPage extends StatefulWidget {
  final GreenMindModel greenMind;

  // ignore: prefer_const_constructors_in_immutables
  DeviceInfoPage({super.key, required this.greenMind});

  @override
  State createState() => _DeviceInfoPageState();
}
///=============================================================================
class _DeviceInfoPageState extends StateSuper<DeviceInfoPage> {
  late GreenMindModel greenMind;
  late TextStyle keyStyle;
  late TextStyle valueStyle;

  @override
  void initState() {
    super.initState();

    greenMind = widget.greenMind;
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
        groupIds: const [UpdaterGroup.greenMindListUpdate],
        builder: (_, ctr, data) {
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
                    child: const Text('GreenMind').color(Colors.grey).fsRRatio(-1.5),
                  ),
                  Text(greenMind.getCaption())
                      .color(Colors.white).bold().fsRRatio(1),
                ],
              )
          ),

          SizedBox(height: 30 * hRel),

          Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                itemCount: greenMind.children.length + 2,
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


            Row(
              children: [
                Expanded(
                    child: CustomRich(
                        children: [
                          Text('ID: ', style: keyStyle),
                          Text('${greenMind.id}', style: valueStyle),
                        ]
                    )
                ),

                Expanded(
                    child: CustomRich(
                        children: [
                          Text('SN: ', style: keyStyle),
                          Text(greenMind.serialNumber, style: valueStyle),
                        ]
                    )
                ),
              ],
            ),

            /// sights/guides
            SizedBox(height: 10 * hRel),
            Row(
              children: [
                Expanded(
                    child: CustomRich(
                        children: [
                          Text('G-Sights: ', style: keyStyle),
                          Text('${greenMind.countOfSights()}', style: valueStyle),
                        ]
                    )
                ),

                Expanded(
                    child: CustomRich(
                        children: [
                          Text('G-Guides: ', style: keyStyle),
                          Text('${greenMind.countOfGuids()}', style: valueStyle),
                        ]
                    )
                ),
              ],
            ),

            SizedBox(height: 10 * hRel),
            Row(
              children: [
                Expanded(
                    child: CustomRich(
                        children: [
                          Text('version of Firmware: ', style: keyStyle),
                          Text('${greenMind.firmwareVersion}', style: valueStyle),
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
                          Text(DateTools.dateOnlyRelative(greenMind.registerDate), style: valueStyle),
                        ]
                    )
                ),
              ],
            ),

            /// connection time
            SizedBox(height: 5 * hRel),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                    child: CustomRich(
                        children: [
                          Text('time of last connection: ', style: keyStyle),
                          Text(greenMind.lastConnectionTime(), style: valueStyle)
                              .color(greenMind.getStatusColor()),
                        ]
                    )
                ),

                const SizedBox(width: 10),

                const CircularIcon(
                  icon: AppIcons.lineChart,
                  itemColor: Colors.white,
                  backColor: AppDecoration.differentColor,
                  size: 24,
                  padding: 8,
                ),
              ],
            ),
          ],
        )
    );
  }

  Widget buildAddNewDevice(){
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
          
          Positioned(
              left: -4,
              top: -2.5,
              child: GestureDetector(
                onTap: onAddChildClick,
                child: const CircularIcon(
                  icon:AppIcons.add,
                  itemColor: Colors.white,
                  backColor: AppDecoration.differentColor,
                  size: 50,
          ),
              )
          )
        ],
      ),
    );
  }

  Widget? itemBuilder(BuildContext context, int index) {
    if(index == 0){
      return buildDetail();
    }

    if(index == 1){
      return buildAddNewDevice();
    }

   final itm = greenMind.children[index-2];

    return buildSightGuideRow(itm);
  }

  Widget buildSightGuideRow(GreenChildModel itm) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: ()=> onChildClick(itm),
        child: CustomCard(
          color: Colors.grey.shade800,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Row(
                    children: [
                      Circle(size: 10, color: itm.getStatusColor()),

                      const SizedBox(width: 8),

                      Text(itm.getCaption())
                          .color(Colors.white).bold(),
                    ],
                  ),

                  ColoredBox(
                      color: itm.typeColor(),
                    child: const SizedBox(width: 10, height: 20),
                  ),
                ],
              ),
            )
        ),
      ),
    );
  }

  void onAddChildClick() {
    AppDialogIris.instance.showYesNoDialog(context,
      yesFn: (_)=> RouteTools.pushPage(context, ConnectChildPage(greenMind: greenMind)),
      desc: AppMessages.trans('doYouAddGreenSight'),
    );
  }

  void onChildClick(GreenChildModel itm) {
    RouteTools.pushPage(context, ChildInfoPage(greenMind: greenMind, greenChild: itm));
  }
}
