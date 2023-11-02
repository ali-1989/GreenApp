import 'package:app/managers/green_mind_manager.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_dialog_iris.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_snack.dart';
import 'package:app/tools/route_tools.dart';
import 'package:app/views/baseComponents/appbar_builder.dart';
import 'package:app/views/pages/setup_green_mind_page.dart';
import 'package:app/views/states/back_bar.dart';
import 'package:app/views/states/user_guide_box.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/api/helpers/focusHelper.dart';

class AddGreenMindPage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  AddGreenMindPage({super.key}) : super();

  @override
  State<AddGreenMindPage> createState() => _AddGreenMindPageState();
}
///=============================================================================
class _AddGreenMindPageState extends StateSuper<AddGreenMindPage> {
  Requester requester = Requester();
  TextEditingController snCtr = TextEditingController();

  @override
  void dispose(){
    snCtr.dispose();
    requester.dispose();
    super.dispose();
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
      child: Column(
        children: [
          SizedBox(height: 25* hRel),

          CustomAppBar(title: AppMessages.addGreenMind),
          SizedBox(height: 15* hRel),

          Align(
            alignment: Alignment.centerLeft,
            child: Transform.translate(
              offset: const Offset(-7, 0),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppDecoration.differentColor,
                  ),
                  onPressed: onSetupGreenMindClick,
                  child: Text(AppMessages.setupGreenMind).fsRRatio(2)
              ),
            ),
          ),

          Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 20 * wRel),
                children: [
                  SizedBox(height: 30 * hRel),
                  UserGuideBox(message: AppMessages.trans('addGreenMindGuide')),

                  SizedBox(height: 14 * hRel),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: snCtr,
                      decoration: AppDecoration.getFilledInputDecoration().copyWith(
                        hintText: 'serial number',
                      ),
                    ),
                  ),

                  SizedBox(height: 14 * hRel),

                  ElevatedButton(
                      onPressed: onFindClick,
                      child: Text(AppMessages.transCap('find')).fsRRatio(2)
                  )
                ],
              ),
          ),

          SizedBox(height: 10 * hRel),
          const BackBar(),
        ],
      ),
    );
  }

  void onSetupGreenMindClick() {
    RouteTools.pushPage(context, const SetupGreenMindPage());
  }

  void onFindClick() async {
    final sn = snCtr.text;

    if(sn.isEmpty){
      AppSnack.showError(context, AppMessages.trans('enterSerialNumber'));
      return;
    }

    await FocusHelper.hideKeyboardByUnFocusRootWait();
    showLoading();
    requestFindGreenMind(sn);
  }

  void requestFindGreenMind(String sn){
    requester.httpRequestEvents.onAnyState = (req) async {
      await hideLoading();
    };

    requester.httpRequestEvents.onFailState = (req, res) async {
      AppSnack.showError(context, AppMessages.dataNotFound);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      AppDialogIris.instance.showYesNoDialog(
          context,
        descView: Text(AppMessages.trans('deviceFoundAddToYourList'))
          .bold().fsRRatio(2),
        yesFn: (_){
            GreenMindManager.addGreenMind(data[Keys.data]);
            //RouteTools.popIfCan(_);
        }
      );
    };

    requester.methodType = MethodType.post;
    requester.bodyJson = {};
    requester.bodyJson!['request'] = 'find_green_mind';
    requester.bodyJson!['serial_number'] = sn;

    requester.prepareUrl();
    requester.request();
  }

}
