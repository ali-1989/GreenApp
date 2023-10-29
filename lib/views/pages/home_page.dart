import 'package:app/managers/home_chart_manager.dart';
import 'package:app/managers/user_guide_manager.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/enums/user_guide_key.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_themes.dart';
import 'package:flutter/material.dart';


import 'package:app/structures/middleWares/requester.dart';
import 'package:iris_tools/widgets/custom_card.dart';

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
        SizedBox(height: 20 * hRel),

        Align(
          alignment: Alignment.centerRight,
          child: Transform.translate(
            offset: const Offset(7, 0),
            child: ElevatedButton.icon(
                onPressed: onAddWidgetClick,
                icon: Image.asset(AppImages.icoAdd, width: 32 * iconR, height: 32*iconR,),
                label: Text('${AppMessages.addWidget}  ').fsRAdd(2),
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
      print(data);
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
  }

  Widget buildWhenThereIsNoChart() {
    if(UserGuideManager.userIsGuided(UserGuideKey.homePageAddWidget)){
      return const Card();
    }

    return Transform.translate(
      offset: const Offset(0, -30),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: CustomCard(
            color: AppDecoration.mainColor.withAlpha(170),
            border: Border.all(color: AppDecoration.buttonBackgroundColor(), width: 2),
            //margin: EdgeInsets.symmetric(vertical: 30),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppMessages.addWidgetGuideText, style: const TextStyle(height: 1.4),)
                      .color(Colors.white).fsRAdd(2),

                  SizedBox(height: 14 * hRel),

                  TextButton(
                      onPressed: onHideAddWidgetGuid,
                      child: Text(AppMessages.iRealized)
                          .bold().color(AppDecoration.buttonBackgroundColor()).fsR(2)
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void onHideAddWidgetGuid() {
  }
}
