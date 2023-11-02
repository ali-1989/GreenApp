import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_sizes.dart';
import 'package:app/tools/route_tools.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/widgets/custom_card.dart';

class BackBar extends StatelessWidget {
  final VoidCallback? onTap;
  const BackBar({super.key, this.onTap}) : super();

  @override
  Widget build(BuildContext context) {
    final irSize = AppSizes.instance.iconRatio;

    return Padding(
      padding: EdgeInsets.only(right: 20, left: 20, bottom: 12 * AppSizes.instance.heightRelative, top: 5),
      child: Material(
        color: AppDecoration.buttonBackgroundColor(),
        child: InkWell(
          overlayColor: MaterialStateProperty.all(Colors.white),
          onTap: (){
            onButtonClick(context);
          },
          child: CustomCard(
            color: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
            child: Row(
              children: [

                Flexible(
                  flex: 2,
                    child: Image.asset(AppImages.icoBackButton, width: 32 * irSize, height: 32 * irSize)),

                Flexible(
                  flex: 8,
                  child: Center(
                    child: Text(AppMessages.back.capitalize)
                        .bold()
                        .color(Colors.white)
                        .fsR(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onButtonClick(BuildContext context) {
    if(!context.mounted){
      return;
    }

    if(onTap != null){
      onTap!.call();
    }
    else {
      RouteTools.popIfCan(context);
    }
  }
}
