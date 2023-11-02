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
import 'package:flutter/material.dart';
import 'package:iris_tools/modules/stateManagers/updater_state.dart';
import 'package:iris_tools/widgets/custom_card.dart';

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
      groupIds: const [UpdaterGroup.grinMindListUpdate],
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
      ],
    );
  }

  Widget? listItemBuilder(BuildContext context, int index) {
    final itm = GreenMindManager.items[index];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: CustomCard(
        color: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('GreenMind')
                  .color(Colors.grey),

                  IconButton(
                    padding: EdgeInsets.zero,
                      visualDensity: VisualDensity(vertical: -4),
                      constraints: BoxConstraints.tightFor(),
                      iconSize: 20,
                      splashRadius: 14,
                      onPressed: onGreenMindSettingsClick(itm),
                      icon: const Icon(AppIcons.settings, color: Colors.white)
                  ),
                ],
              ),

              Row(
                children: [

                  Flexible(
                    flex: 3,
                    fit: FlexFit.tight,
                    child: Text('ID: ${itm.id}')
                        .color(Colors.white).fsRRatio(3),
                  ),

                  Flexible(
                    flex: 7,
                    child: Text('SN: ${itm.serialNumber}')
                        .color(Colors.white).fsRRatio(3),
                  ),
                ],
              ),

              SizedBox(height: 4 * hRel),
              Row(
                children: [
                  Flexible(
                    flex: 5,
                    fit: FlexFit.tight,
                    child: Text('G-Sights: 2')
                        .color(Colors.white).fsRRatio(3),
                  ),

                  Flexible(
                    flex: 5,
                    child: Text('G-Guides: 1')
                        .color(Colors.white).fsRRatio(3),
                  ),
                ],
              ),
            ],
          ),
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
    return (){

    };
  }
}