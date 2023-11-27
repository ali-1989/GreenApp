import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_sheet.dart';
import 'package:app/views/pages/device_info_page.dart';
import 'package:app/views/pages/rename_green_mind.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/updater_state.dart';
import 'package:iris_tools/widgets/custom_card.dart';

import 'package:app/managers/green_mind_manager.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/enums/updater_group.dart';
import 'package:app/structures/models/green_mind_model.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_icons.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/route_tools.dart';
import 'package:app/views/pages/add_green_mind_page.dart';
import 'package:app/views/states/user_guide_box.dart';
import 'package:iris_tools/widgets/icon/circular_icon.dart';
import 'package:iris_tools/widgets/circle.dart';

class DevicesPage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  DevicesPage({super.key});

  @override
  State createState() => DevicesPageState();
}
///=============================================================================
class DevicesPageState extends StateSuper<DevicesPage> {


  @override
  void initState(){
    super.initState();
  }

  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UpdaterBuilder(
      groupIds: const [UpdaterGroup.greenMindListUpdate],
      builder: (_, ctr, data) {
        return buildBody();
      }
    );
  }

  Widget buildBody() {
    return Column(
      children: [
        SizedBox(height: 15 * hRel),

        Align(
          alignment: Alignment.centerRight,
          child: Transform.translate(
            offset: const Offset(7, 0),
            child: ElevatedButton.icon(
              onPressed: onAddGreenMindClick,
              icon: Image.asset(AppImages.icoAdd, width: 32 * iconR, height: 32*iconR),
              label: Text('${AppMessages.addGreenMind}  ').fsRRatio(2),
            ),
          ),
        ),

        SizedBox(height: 15 * hRel),

        Expanded(
          child: Builder(
              builder: (context) {
                if(GreenMindManager.items.isEmpty){
                  return buildWhenThereIsNoItems();
                }

                return ListView.builder(
                  padding: EdgeInsets.only(left: 25 * wRel, right: 25 * wRel, top: 15 * hRel),
                  itemCount: GreenMindManager.items.length,
                  itemBuilder: listItemBuilder,
                );
              }
          ),
        ),

        SizedBox(height: 16 * hRel),
      ],
    );
  }

  Widget? listItemBuilder(BuildContext context, int index) {
    final itm = GreenMindManager.items[index];

    return Padding(
      key: ValueKey(itm.id),
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: [
          CustomCard(
            color: Colors.black,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8),
                topLeft: Radius.circular(8),
              ),
              radius: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Circle(
                    size: 10,
                    color: itm.getStatusColor(),
                  ),

                  Expanded(
                    child: GestureDetector(
                      onTap: ()=> onGreenMindClick(itm),
                      behavior: HitTestBehavior.translucent,
                      child: Center(
                        child: Text(itm.getCaption(),
                          maxLines: 1,
                          textAlign: TextAlign.center,

                        )
                            .color(Colors.white).fsRRatio(3).bold(),
                      ),
                    ),
                  ),

                  IconButton(
                      padding: EdgeInsets.zero,
                      visualDensity: const VisualDensity(vertical: -4),
                      constraints: const BoxConstraints.tightFor(),
                      iconSize: 20,
                      splashRadius: 14,
                      onPressed: onGreenMindSettingsClick(itm),
                      icon: const Icon(AppIcons.settings, color: Colors.white)
                  ),
                ],
              ),
          ),

          CustomCard(
            color: Colors.grey.shade800,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
            radius: 0,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4 * hRel),
                  Row(
                    children: [
                      Flexible(
                        flex: 5,
                        fit: FlexFit.tight,
                        child: Text('G-Sights: ${itm.countOfSights()}')
                            .color(Colors.white).fsRRatio(2),
                      ),

                      Flexible(
                        flex: 5,
                        child: Text('G-Guides: ${itm.countOfGuids()}')
                            .color(Colors.white).fsRRatio(2),
                      ),
                    ],
                  ),
                ],
              ),
          ),
        ],
      ),
    );
  }

  Widget buildWhenThereIsNoItems() {
    return Transform.translate(
      offset: const Offset(0, -40),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: UserGuideBox(message: AppMessages.devicesAddingGuideText),
        ),
      ),
    );
  }

  void onAddGreenMindClick() {
    RouteTools.pushPage(context, AddGreenMindPage());
  }

  VoidCallback onGreenMindSettingsClick(GreenMindModel greenMind) {
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
          RouteTools.pushPage(context, RenameGreenMind(greenMind: greenMind));
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

    return (){
      AppSheet.showSheetMenu(
          context,
          widgets,
          'mind-settings',
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30, top: 8),
      );
    };
  }

  void onGreenMindClick(GreenMindModel itm) {
    RouteTools.pushPage(context, DeviceInfoPage(greenMind: itm));
  }
}
