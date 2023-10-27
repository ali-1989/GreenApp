import 'package:app/structures/abstract/state_super.dart';
import 'package:flutter/material.dart';


import 'package:app/structures/middleWares/requester.dart';

class HomePage extends StatefulWidget {

  // ignore: prefer_const_constructors_in_immutables
  HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => HomePageState();
}
///=============================================================================
class HomePageState extends StateSuper<HomePage> {
  Requester requester = Requester();

  @override
  void initState(){
    super.initState();
    request();
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

  void request(){
print('@@@@@@@@@@@@@@@ hhhhhhhhh');
    requester.httpRequestEvents.onStatusOk = (res, data) async {
      print(data);
      callState();
    };

    requester.httpItem.method = 'POST';
    requester.httpItem.fullUrl = 'http://45.61.49.32:20010/test';
    requester.bodyJson = {};
    requester.bodyJson!['request'] = 'get_green_minds';

    requester.request();
  }
}
