import 'package:app/structures/abstract/state_super.dart';
import 'package:flutter/material.dart';

import 'package:shaped_bottom_bar/models/shaped_item_object.dart';
import 'package:shaped_bottom_bar/shaped_bottom_bar.dart';
import 'package:shaped_bottom_bar/utils/arrays.dart';

import 'package:app/tools/app/app_icons.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_themes.dart';
import 'package:app/views/baseComponents/appbar_builder.dart';
import 'package:app/views/baseComponents/drawer_builder.dart';
import 'package:app/views/pages/home_page.dart';

class LayoutPage extends StatefulWidget{

  const LayoutPage({super.key});

  @override
  State<LayoutPage> createState() => LayoutPageState();
}
///=============================================================================
class LayoutPageState extends StateSuper<LayoutPage> {
  GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();
  int selectedPage = 0;
  late PageController pageController;
  ValueKey<int> bottomBarKey = ValueKey<int>(1);


  @override
  Future<bool> onWillBack<s extends StateSuper>(s state) {
    //MoveToBackground.moveTaskToBack();

    return Future<bool>.value(false);
  }

  @override
  initState(){
    super.initState();

    pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldState,
      appBar: buildAppBar(),
      body: SafeArea(
          bottom: false,
          child: buildBody()
      ),
      drawer: DrawerMenuBuilder.getDrawer(),
      extendBody: true,
      bottomNavigationBar: buildNavBar(),
    );
  }

  Widget buildBody(){
    return Padding(
      padding: EdgeInsets.only(bottom: 50),
      child: PageView(
          physics: NeverScrollableScrollPhysics(),
        allowImplicitScrolling: false,
        controller: pageController,
        children: [
          HomePage(),
        ],
      ),
    );
  }

  AppBar buildAppBar(){
    return AppBarCustom(
      title: Text(AppMessages.appName),
      /*leading: IconButton(
          onPressed: (){
          },
          icon: Icon(AppIcons.list)
      ),*/

      actions: [
        GestureDetector(
          onTap: gotoAidPage,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(AppIcons.cashMultiple, size: 20,),
            ],
          ),
        ),

        IconButton(
            onPressed: (){
              //RouteTools.pushPage(context, SearchPage());
            },
            icon: Icon(AppIcons.search)
        ),
      ],
    );
  }

  Widget buildNavBar(){
    return ShapedBottomBar(
      key: bottomBarKey,
        backgroundColor: AppThemes.instance.currentTheme.primaryColor,
        iconsColor: Colors.black,
        bottomBarTopColor: Colors.transparent,
        shapeColor: AppThemes.instance.currentTheme.differentColor,
        selectedIconColor: Colors.white,
        shape: ShapeType.PENTAGON,
        animationType: ANIMATION_TYPE.FADE,
        selectedItemIndex: selectedPage,
        //textStyle: AppThemes.instance.currentTheme.baseTextStyle,
        listItems: [
          ShapedItemObject(iconData: AppIcons.home, title: AppMessages.home),
        ],
        onItemChanged: (position) {
          selectedPage = position;

          pageController.jumpToPage(selectedPage);
          //setState(() {});
        },
    );
  }

  void gotoPage(idx){
    selectedPage = idx;
    pageController.jumpToPage(idx);

    bottomBarKey = ValueKey(bottomBarKey.value +1);
    setState(() {});
  }

  void gotoAidPage(){
    //AidService.gotoAidPage();
  }
}
