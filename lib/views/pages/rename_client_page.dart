import 'package:app/managers/green_client_manager.dart';
import 'package:app/services/session_service.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/enums/updater_group.dart';
import 'package:app/structures/models/green_client_model.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_sheet.dart';
import 'package:app/tools/app/app_snack.dart';
import 'package:app/tools/route_tools.dart';
import 'package:app/views/components/back_btn.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/modules/stateManagers/updater_state.dart';

class RenameClientPage extends StatefulWidget {
  final GreenClientModel clientModel;

  const RenameClientPage({super.key, required this.clientModel});

  @override
  State createState() => RenameClientPageState();
}
///=============================================================================
class RenameClientPageState extends StateSuper<RenameClientPage> {
  TextEditingController nameCtr = TextEditingController();
  
  @override
  void initState(){
    super.initState();
    
    nameCtr.text = widget.clientModel.caption?? '';
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildBody(),
    );
  }

  Widget buildBody() {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: BackBtn(),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              Text(AppMessages.transCap('renameDevice')).fsR(2),
              const SizedBox(height: 5),

              TextField(
                controller: nameCtr,
                decoration: AppDecoration.outlineBordersInputDecoration,
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: onSaveClick,
                    child: Text(AppMessages.trans('save'))
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  void onSaveClick() async {
    final caption = nameCtr.text.trim();

    if(caption.isEmpty){
      AppSnack.showError(context, AppMessages.trans('enterName'));
      return;
    }

    await FocusHelper.hideKeyboardByUnFocusRootWait();

    showLoading();
    final res = await GreenClientManager.requestReNameClient(widget.clientModel, caption, SessionService.getLastLoginUserId()!);
    await hideLoading();

    if(res){
      UpdaterController.updateByGroup(UpdaterGroup.greenMindUpdate);
      RouteTools.popIfCan(context);
    }
    else {
      AppSheet.showSheetNotice(context, AppMessages.operationFailedTryAgain);
    }
  }
}
