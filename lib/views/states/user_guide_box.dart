import 'package:flutter/material.dart';

import 'package:gradient_borders/gradient_borders.dart';
import 'package:iris_tools/widgets/custom_card.dart';

import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_decoration.dart';

class UserGuideBox extends StatefulWidget {
  final String message;

  // ignore: prefer_const_constructors_in_immutables
  UserGuideBox({
    super.key,
    required this.message,
  });

  @override
  State<StatefulWidget> createState() {
    return UserGuideBoxState();
  }

}
///=============================================================================
class UserGuideBoxState extends State<UserGuideBox> with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;
  List<Color> borderColors = [];
  double oldValue = 0;

  @override
  void initState(){
    super.initState();

    borderColors.add(Colors.white);
    borderColors.add(Colors.white);
    borderColors.add(Colors.white);
    borderColors.add(AppDecoration.differentColor);
    borderColors.add(AppDecoration.differentColor);
    borderColors.add(AppDecoration.differentColor);
    /*borderColors.add(AppDecoration.secondColor);
    borderColors.add(AppDecoration.secondColor);
    borderColors.add(AppDecoration.secondColor);*/

    controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    animation = CurvedAnimation(
      parent: controller,
      curve: Curves.linear,
    );

    controller.forward();
  }

  @override
  void dispose(){
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, child){
        List<Color> colors = borderColors;

        if(animation.value >= oldValue + 0.05) {
          colors = <Color>[borderColors.last,
            ...borderColors.sublist(0, borderColors.length - 1)
          ];

          borderColors.clear();
          borderColors.addAll(colors);
          oldValue = ((animation.value * 100).roundToDouble()) / 100;
        }

        return CustomCard(
          color: AppDecoration.buttonBackgroundColor().withAlpha(230),
          border: GradientBoxBorder(
            width: 2,
              gradient: LinearGradient(
                  colors: colors,
                begin: Alignment.topRight,
                end: Alignment.center,
              ),
          ),
          //border: Border.all(color: AppDecoration.buttonBackgroundColor(), width: 2),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.message, style: const TextStyle(height: 1.4))
                    .color(Colors.white).fsRRatio(2).bold(),

                /*SizedBox(height: 14 * hRel),

                    TextButton(
                        onPressed: onHideAddWidgetGuid,
                        child: Text(AppMessages.iRealized)
                            .bold().color(AppDecoration.buttonBackgroundColor()).fsR(2)
                    )*/
              ],
            ),
          ),
        );
      },
    );
  }
}
