import 'package:flutter/material.dart';

typedef OnChangeTab = void Function(int index);
class MyTabBar extends StatefulWidget {
  final String tab1Text;
  final String tab2Text;
  final int initSelectedIndex;
  final double borderWidth;
  final OnChangeTab? onChangeTab;

  const MyTabBar({
    super.key,
    required this.tab1Text,
    required this.tab2Text,
    this.initSelectedIndex = 0,
    this.borderWidth = 2,
    this.onChangeTab,
  });

  @override
  State createState() => MyTabBarState();
}
///=============================================================================
class MyTabBarState extends State<MyTabBar> {
  late int currentIndex;

  @override
  void initState(){
    super.initState();
    currentIndex = widget.initSelectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [

        Row(
          children: [
            Flexible(
              fit: FlexFit.tight,
              flex: 4,
              child: GestureDetector(
                onTap: (){
                  currentIndex = 0;
                  setState(() {});
                  widget.onChangeTab?.call(0);
                },
                child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: buildTabBorder(0),
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                      color: currentIndex == 0? Colors.white: Colors.grey,
                    ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Text(widget.tab1Text,
                        style: TextStyle(color: currentIndex == 0? Colors.blue: Colors.black38),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const Flexible(
              fit: FlexFit.tight,
              flex: 1,
              child: SizedBox(),
            ),

            Flexible(
              fit: FlexFit.tight,
              flex: 4,
              child: GestureDetector(
                onTap: (){
                  currentIndex = 1;
                  setState(() {});
                  widget.onChangeTab?.call(1);
                },
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: buildTabBorder(1),
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(5),
                        topRight: Radius.circular(5)
                    ),
                    color: currentIndex == 1? Colors.white: Colors.grey,
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Text(widget.tab2Text,
                        style: TextStyle(color: currentIndex == 1? Colors.blue: Colors.black38),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Row(
              children: [
                Flexible(
                  flex: 4,
                  fit: FlexFit.tight,
                  child: Divider(
                    color: currentIndex == 0? Colors.white: Colors.blue,
                    height: widget.borderWidth,
                    thickness: widget.borderWidth,
                    endIndent: currentIndex == 0? 2: 0,
                  ),
                ),

                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Divider(
                    color: Colors.blue,
                    height: widget.borderWidth,
                    thickness: widget.borderWidth,
                  ),
                ),

                Flexible(
                  flex: 4,
                  fit: FlexFit.tight,
                  child: Divider(
                    color: currentIndex == 1? Colors.white: Colors.blue,
                    height: widget.borderWidth,
                    thickness: widget.borderWidth,
                    indent: currentIndex == 1? 2: 0,
                  ),
                )
              ],
            )
        ),

      ],
    );
  }

  Border buildTabBorder(int index) {
    final blueB = BorderSide(color: Colors.blue, width: widget.borderWidth, style: BorderStyle.solid);
    final greyB = BorderSide(color: Colors.grey, width: widget.borderWidth, style: BorderStyle.solid);

    if(currentIndex == index){
      return Border(
        top: blueB,
        bottom: blueB,
        right: blueB,
        left: blueB,
      );
    }

    return Border(
      top: greyB,
      bottom: greyB,
      right: greyB,
      left: greyB,
    );
  }
}
