import 'dart:async';

import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/modules/stateManagers/updater_state.dart';

import 'package:app/managers/green_mind_manager.dart';
import 'package:app/managers/home_widget_manager.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/enums/updater_group.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_broadcast.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_sheet.dart';
import 'package:app/tools/route_tools.dart';
import 'package:app/views/components/home_widget_view.dart';
import 'package:app/views/pages/add_widget_page.dart';
import 'package:app/views/states/user_guide_box.dart';

class HomePage extends StatefulWidget {

  // ignore: prefer_const_constructors_in_immutables
  HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => HomePageState();
}
///=============================================================================
class HomePageState extends StateSuper<HomePage> {
  late Timer onHourUpdateTimer;

  @override
  void initState(){
    super.initState();
    
    UpdaterController.addGroupListener([UpdaterGroup.homeWidgetUpdate], onUpdateWidget);
    onHourUpdateTimer = Timer.periodic(const Duration(minutes: 30), (timer) {callState();});
  }

  @override
  void dispose(){
    super.dispose();

    UpdaterController.removeGroupListener(onUpdateWidget);
    onHourUpdateTimer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return buildBody();
  }

  Widget buildBody(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15 * hRel),

        Align(
          alignment: Alignment.centerRight,
          child: Transform.translate(
            offset: const Offset(7, 0),
            child: ElevatedButton.icon(
                onPressed: onAddWidgetClick,
                icon: Image.asset(AppImages.icoAdd, width: 32 * iconR, height: 32*iconR,),
                label: Text('${AppMessages.addWidget}  ').fsRRatio(2),
            ),
          ),
        ),

        Expanded(
          child: Builder(
            builder: (context) {
              if(HomeWidgetManager.current!.items.isEmpty){
                return buildWhenThereIsNoChart();
              }

              return ReorderableListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                  onReorder: (old, newOrder) async {
                    int min = MathHelper.minInt(old, newOrder);
                    int max = MathHelper.maxInt(old, newOrder);
                    bool toTop = newOrder < old;

                    if(toTop){
                      final r1Order = HomeWidgetManager.current!.items[newOrder].order;

                      HomeWidgetManager.current!.items.getRange(min, max)
                          .forEach((element) {
                        element.order++;
                      });

                      final r2 = HomeWidgetManager.current!.items[old];
                      r2.order = r1Order;
                    }
                    else {
                      final ic = MathHelper.minInt(newOrder, HomeWidgetManager.current!.items.length-1);
                      final r1Order = HomeWidgetManager.current!.items[ic].order;

                      HomeWidgetManager.current!.items.getRange(min, max)
                          .forEach((element) {
                        element.order--;
                      });

                      final r2 = HomeWidgetManager.current!.items[old];
                      r2.order = r1Order;
                    }

                    HomeWidgetManager.current!.sortItemsByOrder();
                    HomeWidgetManager.current!.notifyUpdate();

                    for(final k in HomeWidgetManager.current!.items){
                      await HomeWidgetManager.current!.sink(k);
                    }
                  },
                itemCount: HomeWidgetManager.current!.items.length,
                itemBuilder: listItemBuilder,
              );
            }
          ),
        ),
      ],
    );
  }

  Widget listItemBuilder(BuildContext context, int index) {
    final itm = HomeWidgetManager.current!.items[index];

    if(index == HomeWidgetManager.current!.items.length-1){
      return Padding(
        key: ValueKey(itm.clientId),
          padding: EdgeInsets.only(bottom: 15 * hRel),
        child: HomeWidgetView(
          homeWidget: itm,
        ),
      );
    }

    return HomeWidgetView(
      key: ValueKey(itm.clientId),
      homeWidget: itm,
    );
  }

  void onAddWidgetClick() {
    //UserGuideManager.userIsGuided(UserGuideKey.homePageAddWidget)
    if(GreenMindManager.current!.items.isEmpty){
      AppSheet.showSheetOneAction(
          context,
          AppMessages.addWidgetButtonGuideText,
        onButton: (){
          AppBroadcast.layoutPageKey.currentState?.gotoPage(1);
        }
      );

      return;
    }

    RouteTools.pushPage(context, AddWidgetPage());
  }

  Widget buildWhenThereIsNoChart() {
    return Transform.translate(
      offset: const Offset(0, -40),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: UserGuideBox(message: AppMessages.homeWidgetGuideText),
        ),
      ),
    );
  }

  void onUpdateWidget(UpdaterGroupId p1) {
    callState();
  }
}
