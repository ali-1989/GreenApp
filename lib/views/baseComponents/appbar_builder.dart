import 'package:flutter/material.dart';

import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_tools/widgets/circle.dart';
import 'package:iris_tools/widgets/colored_space.dart';
import 'package:iris_tools/widgets/path/paths.dart';
import 'package:iris_tools/widgets/shadow.dart';

import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/enums/app_events.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_broadcast.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_images.dart';

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
  void initState(){
    super.initState();
    EventNotifierService.addListener(AppEvents.networkStateChange, onNetChange);
    EventNotifierService.addListener(AppEvents.webSocketStateChange, onWsChange);
  }

  @override
  void dispose(){
    EventNotifierService.removeListener(AppEvents.networkStateChange, onNetChange);
    EventNotifierService.removeListener(AppEvents.webSocketStateChange, onWsChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.ltr,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        /// image
        Padding(
            padding: EdgeInsets.only(left: 25* wRel, right: 25* wRel),
          child: Builder(
            builder: (context) {
              if(true) {
                return Image.asset(
                    AppImages.icoUser, width: 50 * iconR, height: 50 * iconR);
              }

              return ShadowBuilder(
                  pathBuilder: (siz){
                    return Paths.buildSquareFatSide(siz,  20);
                  },
                    transparentFill: false,
                    shadows: const [
                      Shadow(color: Colors.black,
                          offset: Offset(0, 1),
                          blurRadius: 5
                      ),

                    ],
                child: ClipPath(
                  clipper: PathClipper(
                      builder: (siz){
                        return Paths.buildSquareFatSide(siz,  20);
                      }
                  ),
                  child: const ColoredSpace(width: 63, height: 63),
                ),
              );
            }
          ),
        ),


        /// title
        Expanded(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: AppDecoration.secondColor,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15))
              ),
              child: SizedBox(
                height: 35 * hRel,
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: widget.titleView?? Text(widget.title?? '')
                            .bold().color(Colors.white).fsRRatio(3),
                      ),
                    ),

                    Column(
                      children: [
                        Circle(size: 3, color: AppBroadcast.isNetConnected? Colors.green : Colors.red),
                        Circle(size: 3, color: AppBroadcast.isWsConnected? Colors.green : Colors.red),
                      ],
                    ),
                  ],
                ),
              ),
            )
        )
      ],
    );
  }

  void onNetChange({data}) {
    callState();
  }

  void onWsChange({data}) {
    callState();
  }
}
