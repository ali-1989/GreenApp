import 'package:flutter/material.dart';

import 'package:app/structures/abstract/state_super.dart';
import 'package:app/system/extensions.dart';

class ChartPage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  ChartPage({super.key});

  @override
  State createState() => ChartPageState();
}
///=============================================================================
class ChartPageState extends StateSuper<ChartPage> {


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
      child: Text('Soon...').bold().fsR(10),
    );
  }
}
