import 'package:flutter/material.dart';

import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/widgets/icon/circular_icon.dart';

import 'package:app/managers/green_client_manager.dart';
import 'package:app/managers/green_mind_manager.dart';
import 'package:app/managers/home_widget_manager.dart';
import 'package:app/services/session_service.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/models/green_child_model.dart';
import 'package:app/structures/models/green_client_model.dart';
import 'package:app/structures/models/green_mind_model.dart';
import 'package:app/structures/models/home_widget_model.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_icons.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_toast.dart';
import 'package:app/views/baseComponents/appbar_builder.dart';

class AddWidgetPage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  AddWidgetPage({super.key}) : super();

  @override
  State<AddWidgetPage> createState() => _AddWidgetPageState();
}
///=============================================================================
class _AddWidgetPageState extends StateSuper<AddWidgetPage> {
 late List<GreenMindModel> greenMindList;
 List<GreenChildModel> children = [];
 List<GreenClientModel> clientList = [];
 int greenSelectedIndex = 0;
 int childSelectedIndex = 0;

  @override
  void initState(){
    super.initState();

    greenMindList = GreenMindManager.current!.items;
    generateChildren();
    generateClient();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        body: buildBody(),
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
      child: SizedBox.expand(
        child: Column(
          children: [
            SizedBox(height: 25* hRel),

            CustomAppBar(title: AppMessages.addGreenMind),
            SizedBox(height: 4* hRel),

            ColoredBox(
              color: Colors.black,
              child: SizedBox(
                height: 98,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  scrollDirection: Axis.horizontal,
                  itemCount: greenMindList.length,
                    itemBuilder: greenMindItemBuilder
                ),
              ),
            ),

            Expanded(
              child: Builder(
                builder: (context) {
                  if(children.isEmpty){
                    return SizedBox.expand(
                      child: Center(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: const Text(' Without Device').bold(),
                          ),
                        ),
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Column(
                      children: [
                        /// Device rail
                        ColoredBox(
                          color: Colors.black,
                          child: SizedBox(
                            height: 98,
                            child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                scrollDirection: Axis.horizontal,
                                itemCount: children.length,
                                itemBuilder: childrenItemBuilder
                            ),
                          ),
                        ),

                        /// client grid
                        Expanded(
                            child: Builder(
                                builder: (context) {
                                  if(clientList.isEmpty){
                                    return SizedBox.expand(
                                      child: Center(
                                        child: Card(
                                          child: Padding(
                                            padding: const EdgeInsets.all(15.0),
                                            child: const Text(' Without Client').bold(),
                                          ),
                                        ),
                                      ),
                                    );
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: ColoredBox(
                                      color: Colors.white.withAlpha(120),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: GridView.builder(
                                          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                          ),
                                          scrollDirection: Axis.vertical,
                                          itemCount: clientList.length,
                                          itemBuilder: clientItemBuilder,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                            )
                        ),
                      ],
                    ),
                  );
                }
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget greenMindItemBuilder(BuildContext context, int index) {
    final green = greenMindList[index];

    return GestureDetector(
      onTap: ()=> onGreenMindClick(index, green),
      child: SizedBox(
        width: 100,
        height: 90,
        child: Card(
          color: greenSelectedIndex == index ? Colors.blue : AppDecoration.mainColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const Text('GreenMind').color(Colors.white70),
                const SizedBox(height: 13),
                Text(green.getCaption(), textAlign: TextAlign.center,)
                    .color(Colors.white).bold()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget childrenItemBuilder(BuildContext context, int index) {
    final green = children[index];

    return GestureDetector(
      onTap: ()=> onChildClick(index, green),
      child: SizedBox(
        width: 100,
        height: 90,
        child: Card(
          color: childSelectedIndex == index ? Colors.blue : AppDecoration.mainColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const Text('Device').color(Colors.white70),
                const SizedBox(height: 13),
                Text(green.getCaption(), textAlign: TextAlign.center)
                    .color(Colors.white).bold()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget clientItemBuilder(BuildContext context, int index) {
    final client = clientList[index];
    bool isAddToHome = HomeWidgetManager.current!.existOnHome(client.id);

    return Card(
      color: isAddToHome ? Colors.green : AppDecoration.mainColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Client').color(Colors.white70),
            Text(client.getCaption(), textAlign: TextAlign.center)
                .color(Colors.white).bold(),

            Center(
              child: GestureDetector(
                onTap: ()=> addRemoveClick(client, isAddToHome),
                child: CircularIcon(
                  backColor: isAddToHome? Colors.red : Colors.blue,
                  icon: isAddToHome? Icons.remove: AppIcons.add,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onGreenMindClick(int idx, GreenMindModel green) {
    greenSelectedIndex = idx;
    generateChildren();

    callState();
  }

  void onChildClick(int index, GreenChildModel green) {
    childSelectedIndex = index;
    generateClient();

    callState();
  }

 void generateChildren() {
   children.clear();

   if(greenMindList.isNotEmpty) {
     children.addAll(greenMindList[greenSelectedIndex].children);
   }

   childSelectedIndex = 0;
 }

 void generateClient() {
   clientList.clear();

   if(children.isNotEmpty) {
     final x = children[childSelectedIndex];

     clientList.addAll(GreenClientManager.current!.items.where((element) => element.ownerId == x.id));
   }
 }

  void addRemoveClick(GreenClientModel client, bool isAddToHome) {
    if(isAddToHome){
      HomeWidgetManager.current!.removeWidget(client.id);
      AppToast.showToast(context, 'widget removed from Home screen.');
    }
    else {
      final child = children[childSelectedIndex];
      final mind = greenMindList[greenSelectedIndex];

      final hw = HomeWidgetModel();
      hw.userId = SessionService.getLastLoginUserId()!;
      hw.clientId = client.id;
      hw.greenMindId = mind.id;
      hw.childId = child.id;
      hw.registerDate = DateHelper.nowMinusUtcOffset();
      hw.order = HomeWidgetManager.current!.getLastOrder() + 1;

      HomeWidgetManager.current!.addHomeWidget(hw);
      AppToast.showToast(context, 'widget added to Home screen.');
    }

    callState();
  }

}
