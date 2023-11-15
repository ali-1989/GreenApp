import 'package:flutter/material.dart';

import 'package:app/structures/abstract/state_super.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/views/baseComponents/appbar_builder.dart';

class AddWidgetPage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  AddWidgetPage({super.key}) : super();

  @override
  State<AddWidgetPage> createState() => _AddWidgetPageState();
}
///=============================================================================
class _AddWidgetPageState extends StateSuper<AddWidgetPage> {
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
          SizedBox(height: 4* hRel),


        ],
      ),
    );
  }
}
