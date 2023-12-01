import 'package:flutter/material.dart';

import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:awesome_bottom_bar/widgets/inspired/inspired.dart';
import 'package:iris_tools/widgets/keep_alive_wrap.dart';

import 'package:app/managers/green_mind_manager.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/views/baseComponents/appbar_builder.dart';
import 'package:app/views/pages/automation_page.dart';
import 'package:app/views/pages/chart_page.dart';
import 'package:app/views/pages/devices_page.dart';
import 'package:app/views/pages/home_page.dart';
import 'package:app/views/pages/setting_page.dart';

class LayoutPage extends StatefulWidget {

  const LayoutPage({super.key});

  @override
  State<LayoutPage> createState() => LayoutPageState();
}
///=============================================================================
class LayoutPageState extends StateSuper<LayoutPage> {
  /// for drawer menu
  GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();
  int selectedPage = 2;
  late PageController pageController;

  @override
  Future<bool> onWillBack<s extends StateSuper>(s state) {
    //MoveToBackground.moveTaskToBack();

    return Future<bool>.value(false);
  }

  @override
  initState(){
    super.initState();

    pageController = PageController(initialPage: selectedPage);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        key: scaffoldState,
        body: buildBody(),
        extendBody: true,
        bottomNavigationBar: buildNavBar(),
      ),
    );
  }

  Widget buildBody(){
    return DecoratedBox(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppImages.homeBackG),
          fit: BoxFit.cover,
        )
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: Column(
          children: [
            SizedBox(height: 25* hRel),

            buildAppBar(),
            SizedBox(height: 4* hRel),

            Expanded(
              child: PageView(
                  physics: const NeverScrollableScrollPhysics(),
                allowImplicitScrolling: false,
                controller: pageController,
                children: [
                  SettingsPage(),
                  DevicesPage(),
                  KeepAliveWrap(child: HomePage()),
                  AutomationPage(),
                  ChartPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAppBar(){
    return CustomAppBar(
      title: getTitle()
    );
  }

  String getTitle(){
    switch (selectedPage){
      case 0:
        return 'Settings';
      case 1:
        return 'Devices';
      case 2:
        return 'Home';
      case 3:
        return 'Automation';
      case 4:
        return 'Charts';
      default:
        return '';
    }
  }

  Widget buildNavBar(){
    final icoSize = 20 *iconR;

    return BottomBarInspiredOutside(
      backgroundColor: AppDecoration.mainColor,
      color: Colors.white,
      colorSelected: Colors.white,
      itemStyle: ItemStyle.circle,
      borderRadius: BorderRadius.circular(5),
      radius: 20,
      animated: true,
      height: 30,
      top: -20,
      sizeInside: 55,
      chipStyle: const ChipStyle(background: AppDecoration.mainColor, color: Colors.white, convexBridge: false, notchSmoothness: NotchSmoothness.softEdge),
      indexSelected: selectedPage,
      onTap: onChangePage,
      items: [
        TabItem(icon: Image.asset(AppImages.icoBNavigatorSetting, width: icoSize, height: icoSize)),
        TabItem(icon: Image.asset(AppImages.icoBNavigatorDevices, width: icoSize, height: icoSize)),
        TabItem(icon: Image.asset(AppImages.icoBNavigatorHome, width: icoSize, height: icoSize)),
        TabItem(icon: Image.asset(AppImages.icoBNavigatorNetwork, width: icoSize, height: icoSize)),
        TabItem(icon: Image.asset(AppImages.icoBNavigatorChart, width: icoSize, height: icoSize)),
      ],
    );
  }

  void gotoPage(idx){
    selectedPage = idx;
    pageController.jumpToPage(idx);

    //bottomBarKey = ValueKey(bottomBarKey.value +1);
    setState(() {});
  }

  onChangePage(int position) {
    selectedPage = position;
    callState();
    pageController.jumpToPage(selectedPage);

    /// for detect disConnected devices and show.
    if(position == 1){
      GreenMindManager.current!.startRefreshGreenMindTimer();
    }
    else {
      GreenMindManager.current!.stopRefreshGreenMindTimer();
    }
  }
}
