import 'package:app/structures/abstract/state_super.dart';
import 'package:app/system/extensions.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  SettingsPage({super.key});

  @override
  State createState() => SettingsPageState();
}
///=============================================================================
class SettingsPageState extends StateSuper<SettingsPage> {


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