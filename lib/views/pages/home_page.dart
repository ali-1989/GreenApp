import 'package:app/structures/abstract/state_super.dart';
import 'package:flutter/material.dart';


import 'package:app/structures/middleWares/requester.dart';

class HomePage extends StatefulWidget {

  HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => HomePageState();
}
///==================================================================================
class HomePageState extends StateSuper<HomePage> {
  Requester requester = Requester();


  @override
  void initState(){
    super.initState();


  }

  @override
  void dispose(){
    requester.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center();
  }

  Widget buildBody(){
    return SizedBox();
  }


}
