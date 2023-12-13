import 'package:flutter/material.dart';

import 'package:app/structures/abstract/state_super.dart';
import 'package:app/system/extensions.dart';

class AutomationPage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  AutomationPage({super.key});

  @override
  State createState() => AutomationPageState();
}
///=============================================================================
class AutomationPageState extends StateSuper<AutomationPage> {


  @override
  void initState(){
    super.initState();
  }

  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildBody();
  }

  Widget buildBody() {
    return Center(
      child: Text('coming Soon...').bold().fsR(10),
    );
  }
}
