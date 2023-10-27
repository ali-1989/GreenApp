import 'package:app/structures/abstract/state_super.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/views/paths.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/widgets/colored_space.dart';
import 'package:iris_tools/widgets/shadow.dart';


class CustomAppBar extends StatefulWidget {
  final Widget? titleView;
  final String? title;
  const CustomAppBar({super.key, this.titleView, this.title});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}
///=============================================================================
class _CustomAppBarState extends StateSuper<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.ltr,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
            padding: EdgeInsets.only(left: 30* wRel, right: 25* wRel),
          child: Image.asset(AppImages.icoUser, width: 50* iconR, height: 50*iconR),
        ),

        /*DecoratedBox(
            decoration: ShapeDecoration(
                shape: ContinuousRectangleBorder(
                    //borderRadius: BorderRadius.circular(30)
                    borderRadius: SmoothBorderRadius.all(SmoothRadius( cornerRadius: 60, cornerSmoothing: 0.5))
                ),
              color: Colors.red,
            ),
          child: SizedBox(width: 70, height: 70),
        ),*/

        ShadowBox(
          offset: Offset(0, 3),
          blurRadius: 2,
          circular: 25,
          spreadRadius: 0,
          child: ClipPath(
            clipper: PathClipper(
                builder: (siz){
                  return Paths.buildSquareFatSide(siz,  20);
                }
            ),
            child: ColoredSpace(width: 63, height: 63),
          ),
        ),
        
        Expanded(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: AppDecoration.secondColor,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15))
              ),
              child: SizedBox(
                height: 35 * hRel,
                child: Center(
                  child: widget.titleView?? Text(widget.title?? '')
                      .bold().color(Colors.white).fsRHole(3),
                ),
              ),
            )
        )
      ],
    );
  }
}