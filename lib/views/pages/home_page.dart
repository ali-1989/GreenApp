import 'package:flutter/material.dart';

import 'package:app/managers/green_mind_manager.dart';
import 'package:app/managers/home_chart_manager.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_broadcast.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_sheet.dart';
import 'package:app/tools/route_tools.dart';
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
  Requester requester = Requester();

  @override
  void initState(){
    super.initState();
    request();
  }

  @override
  void dispose(){
    requester.dispose();

    super.dispose();
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
              if(HomeChartManager.list.isEmpty){
                return buildWhenThereIsNoChart();
              }

              return ListView.builder(
                itemCount: 0,
                itemBuilder: listItemBuilder,
              );
            }
          ),
        ),
      ],
    );
  }

  void request(){
    requester.httpRequestEvents.onStatusOk = (res, data) async {
      print(data);//todo.
      callState();
    };

    requester.httpItem.method = 'POST';
    requester.httpItem.fullUrl = 'http://45.61.49.32:20010/test';
    requester.bodyJson = {};
    requester.bodyJson!['request'] = 'get_green_minds';

    requester.request();
  }

  Widget? listItemBuilder(BuildContext context, int index) {
  }

  void onAddWidgetClick() {
    //UserGuideManager.userIsGuided(UserGuideKey.homePageAddWidget)
    if(GreenMindManager.items.isEmpty){
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
}
