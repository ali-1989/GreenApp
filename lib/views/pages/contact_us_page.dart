import 'package:app/structures/abstract/state_super.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/widgets/maxWidth.dart';

import 'package:app/services/session_service.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_sheet.dart';
import 'package:app/tools/route_tools.dart';

class ContactUsPage extends StatefulWidget{

  const ContactUsPage({Key? key}) : super(key: key);

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}
///=============================================================================
class _ContactUsPageState extends StateSuper<ContactUsPage> {
  TextEditingController textCtr = TextEditingController();
  Requester requester = Requester();

  @override
  void dispose(){
    textCtr.dispose();
    requester.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }

  Widget buildBody(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [


        Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              child: TextField(
                controller: textCtr,
                minLines: 8,
                maxLines: 12,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(),
                ),
              ),
            ),
        ),

        const SizedBox(height: 20,),
        MaxWidth(
            maxWidth: 300,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSendCall,
                child: Text(AppMessages.send),
              ),
            )
        )
      ],
    );
  }

  void onSendCall(){
    FocusHelper.hideKeyboardByUnFocusRoot();
    final txt = textCtr.text.trim();

    if(txt.isEmpty){
      //AppSnack.showError(context, AppMessages.contactUsEmptyPrompt);
      return;
    }

    requestSendData();
  }

  void requestSendData() async {
    final txt = textCtr.text.trim();

    final js = <String, dynamic>{};
    js[Keys.request] = 'send_ticket_data';
    js[Keys.requesterId] = SessionService.getLastLoginUser()?.userId;
    js[Keys.data] = txt;

    requester.bodyJson = js;

    requester.httpRequestEvents.onFailState = (req, r) async {
      hideLoading();

      AppSheet.showSheetOk(context, AppMessages.operationFailed);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      hideLoading();

      AppSheet.showSheetOneAction(context, AppMessages.operationSuccess, onButton: (){
        RouteTools.popTopView(context: context);
      });
    };

    showLoading();
    requester.prepareUrl();
    requester.request();
  }
}
