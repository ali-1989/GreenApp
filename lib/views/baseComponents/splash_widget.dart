import 'package:flutter/material.dart';

import 'package:animate_do/animate_do.dart';
import 'package:iris_tools/api/helpers/colorHelper.dart';

import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_decoration.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Material(
        child: DecoratedBox(
          decoration: BoxDecoration(
              gradient: RadialGradient(
                radius: 1,
                focalRadius: 0.0,
                tileMode: TileMode.clamp,
                colors: [
                  AppDecoration.mainColor,
                  AppDecoration.mainColor,
                  ColorHelper.darkPlus(AppDecoration.mainColor, val: 0.02),
                  ColorHelper.darkPlus(AppDecoration.mainColor, val: 0.04),
                  ColorHelper.darkPlus(AppDecoration.mainColor, val: 0.06),
                  ColorHelper.darkPlus(AppDecoration.mainColor, val: 0.09),
                ],
              )
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              FadeIn(
                duration: const Duration(milliseconds: 700),
                child: const Text('Green Oasis',
                  style: TextStyle(shadows: [
                    Shadow(color: Colors.grey, blurRadius: 2, offset: Offset(2,2)),
                    Shadow(color: Colors.grey, blurRadius: 5, offset: Offset(4,4)),
                  ], color: Colors.white),
                ).bold().fsR(20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
