import 'package:app/managers/home_widget_manager.dart';
import 'package:app/structures/models/home_widget_model.dart';
import 'package:app/tools/app/app_db.dart';
import 'package:app/tools/app/app_icons.dart';
import 'package:app/tools/app/app_pop.dart';
import 'package:app/tools/app/app_snack.dart';
import 'package:app/tools/route_tools.dart';
import 'package:app/views/pages/full_chart_page.dart';
import 'package:app/views/pages/rename_client_page.dart';
import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/modules/stateManagers/updater_state.dart';
import 'package:iris_tools/widgets/circle_bordering.dart';
import 'package:iris_tools/widgets/custom_card.dart';

import 'package:app/managers/client_data_manager.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/enums/app_events.dart';
import 'package:app/structures/enums/updater_group.dart';
import 'package:app/structures/models/client_data_model.dart';
import 'package:app/structures/models/green_client_model.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';

class HomeWidgetView extends StatefulWidget {
  final HomeWidgetModel homeWidget;

  // ignore: prefer_const_constructors_in_immutables
  HomeWidgetView({
    super.key,
    required this.homeWidget,
  });

  @override
  State createState() => _HomeWidgetViewState();
}
///=============================================================================
class _HomeWidgetViewState extends StateSuper<HomeWidgetView> {
  GreenClientModel? clientModel;
  ClientDataModel? lastDataModel;
  List<ClientDataModel> dataList = [];
  double yMinValue = 0;
  double yMaxValue = 1;
  double yLineStep = 1;
  double xMinValue = 0;
  double xMaxValue = 8;
  double xLineStep = 1;
  List<FlSpot> dots = [];
  Map<int, DateTime> bottomSteps = {};
  bool errorOccurredInLiveData = false;

  @override
  void initState(){
    super.initState();

    clientModel = widget.homeWidget.getClient();
    print('ohhhhhhhhhhhhh ${clientModel == null} , ${widget.homeWidget.clientId} ');
    AppDB.db.logRows(AppDB.tbGreenClient);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if(mounted){
        UpdaterController.addGroupListener([UpdaterGroup.greenClientUpdate], onNewDataListener);
        EventNotifierService.addListener(AppEvents.networkConnected, onReConnectNet);
        prepareLastModel();
        prepareDataList();
        requestNewData();
      }
    });
  }

  @override
  void dispose(){
    UpdaterController.removeGroupListener(onNewDataListener);
    EventNotifierService.removeListener(AppEvents.networkConnected, onReConnectNet);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(clientModel == null){
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: CustomCard(
          color: Colors.black,
          child: SizedBox(
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Ohhhhhhhh')
                    .color(Colors.white).fsR(5),
                const Text('CAN NOT READ DATA')
                    .color(Colors.white).fsR(5),
              ],
            ),
          ),
        ),
      );
    }


    if(clientModel!.isVolume()){
      return buildSwitch();
    }

    return buildChartMode();
  }


  Widget buildSwitch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: CustomCard(
          color: Colors.black,
          radius: 30,
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// switch button or loading
                    Builder(builder: (_){
                      if(lastDataModel == null){
                        return const Center(
                          child: SizedBox(
                            width: 35,
                            height: 35,
                            child: FittedBox(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      }

                      return SizedBox(
                        key: ValueKey(lastDataModel!.isVolumeActive()),
                        height: 40,
                        child: LiteRollingSwitch(
                          value: lastDataModel!.isVolumeActive(),
                          width: 90,
                          textOn: 'on',
                          textOff: 'off',
                          colorOn: Colors.greenAccent[700]!,
                          colorOff: Colors.redAccent[700]!,
                          iconOn: Icons.lightbulb_outline,
                          iconOff: Icons.power_settings_new,
                          textSize: AppDecoration.fontSizeAddRatio(3),
                          onChanged: (bool state) {
                            if(state){
                              lastDataModel!.data = '1';
                            }
                            else {
                              lastDataModel!.data = '0';
                            }

                            sendSwitchState(state);
                          },
                          onTap: (){},
                          onDoubleTap: (){},
                          onSwipe: (){},
                        ),
                      );
                    }),

                    /// settings icon
                    const SizedBox(width: 10),
                    Builder(
                        builder: (context) {
                          return GestureDetector(
                              onTap: () => onSettingsIconClick( context),
                              child: const Icon(AppIcons.settings, color: Colors.white, size: 20)
                          );
                        }
                    )
                  ],
                ),

                const SizedBox(height: 10),

                /// name
                Text(clientModel!.getCaption())
                    .color(Colors.blue).bold().fsRRatio(2),

                /// time
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time_filled_outlined, color: Colors.white, size: 18),

                    const SizedBox(width: 4),

                    Builder(
                        builder: (_){
                          if(lastDataModel == null){
                            return const Text('-');
                          }

                          return Text(lastDataModel!.lastConnectionTime())
                              .color(Colors.white);
                        }
                    ),

                    /*FutureBuilder(
                        future: widget.clientModel.lastConnectionTime(),
                        builder: (_, snap){
                          if(snap.data == null || snap.hasError){
                            return const SizedBox();
                          }

                          return Text(snap.data!)
                              .color(Colors.white);
                        }
                    ),*/
                  ],
                )
              ]
          )
      ),
    );
  }

  Widget buildChartMode() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: CustomCard(
        color: Colors.black,
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: widget.homeWidget.showChart? 240 : 70,
          child: Builder(
            builder: (context) {
              return Column(
                children: [
                  /// live data
                  SizedBox(
                    height: 70,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        /// settings icon
                        Positioned(
                          top: 7,
                          left: 7,
                          child: Builder(
                              builder: (ctx) {
                                return GestureDetector(
                                    onTap: ()=> onSettingsIconClick(ctx),
                                    behavior: HitTestBehavior.translucent,
                                    child: const Icon(Icons.settings, color: Colors.white, size: 20)
                                );
                              }
                          ),
                        ),

                        /// icon, number
                        Positioned(
                          top:7,
                          right: 7,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Builder(
                                    builder: (_){
                                      if(errorOccurredInLiveData){
                                        return Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Text(' ☹')
                                                .color(Colors.white).fsR(15),

                                            const Text(' ooh')
                                                .color(Colors.white).fsMultiInRatio(14),
                                          ],
                                        );
                                      }

                                      if(lastDataModel == null){
                                        return const CircularProgressIndicator(color: Colors.white);
                                      }

                                      return Transform.translate(
                                        offset: const Offset(0, 0),
                                        child: CircleBordering(
                                          borderColor: Colors.amber,
                                          borderWidth: 1.3,
                                          radius: 38,
                                          padding: const EdgeInsets.only(top: 3),
                                          child: Text(lastDataModel!.data.toString())
                                              .color(Colors.white).bold().fsRRatio(8),
                                        ),
                                      );
                                    }
                                ),

                                const SizedBox(width: 6),
                                Icon(clientModel!.getTypeIcon(), color: Colors.white),
                              ],
                            ),
                          ),
                        ),

                        /// name
                        Positioned(
                          bottom: 5,
                          left: 7,
                          right: 90,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(clientModel!.getCaption(), maxLines: 1,)
                                        .color(Colors.blue).bold().fsR(1),
                                  ),

                                  const Text('  Of ', maxLines: 1,)
                                      .color(Colors.amber),
                                  Flexible(
                                    child: Text(widget.homeWidget.getMind()?.getCaption()?? '', maxLines: 1,)
                                        .color(Colors.white),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 1),
                              Row(
                                children: [
                                  /*const Text('last update: ')
                                      .color(Colors.grey).bold().fsR(1),*/

                                  Text(lastDataModel?.lastConnectionTime()?? '-')
                                      .color(Colors.grey).bold(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// chart
                  Visibility(
                    visible: widget.homeWidget.showChart,
                    child: SizedBox(
                      height: 170,
                      child: ColoredBox(
                        //color: Colors.grey[800]!,//AppDecoration.differentColor,
                        color: Colors.black,
                        child: Builder(
                            builder: (_){
                              if(dataList.isEmpty && lastDataModel == null && !errorOccurredInLiveData){
                                return const SizedBox(
                                    width: 100,
                                    child: UnconstrainedBox(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    )
                                );
                              }

                              if(dataList.isEmpty){
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('🗑')
                                        .color(Colors.white).fsR(10),
                                    const SizedBox(height: 12),
                                    Text(AppMessages.transCap('noDataForChart'))
                                        .color(Colors.white).fsRRatio(1).bold(),
                                  ],
                                );
                              }

                              return GestureDetector(
                                onTap: onShowFullScreenClick,
                                  behavior: HitTestBehavior.translucent,
                                  child: LineChart(genChartData())
                              );
                            }
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          )
        ),
      ),
    );
  }

  void prepareLastModel() async {
    if(clientModel == null){
      return;
    }

    final last = await ClientDataManager.fetchLastData(clientModel!.id, false);

    if(last is ClientDataModel){
      lastDataModel = last;
      errorOccurredInLiveData = false;
    }
    else {
      errorOccurredInLiveData = true;
    }

    callState();
  }

  void prepareDataList() async {
    if(clientModel == null){
      return;
    }

    DateTime to = DateHelper.nowMinusUtcOffset();
    DateTime from = to.subtract(const Duration(hours: 24));

    final list = await ClientDataManager.fetchFor(clientModel!.id, from, to: to);

    dataList.clear();
    dataList.addAll(list);

    prepareMinMaxAndDots(from);

    callState();
  }

  LineChartData genChartData() {
    final bars = <LineChartBarData>[];

    bars.add(
      LineChartBarData(
          show: true,
        isCurved: true,
        color: Colors.white,
        barWidth: 1,
        preventCurveOverShooting: false,
        curveSmoothness: 0.2,
        //lineChartStepData: LineChartStepData(stepDirection: 5),
        isStepLineChart: false, //break Line, no Curve
        spots: dots,
      ),
    );

    return LineChartData(
        backgroundColor: AppDecoration.mainColor,
        minX: xMinValue,
        maxX: xMaxValue, //0,1,...,8 (9 step)
        minY: yMinValue,
        maxY: yMaxValue,
        lineBarsData: bars,
        titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          //axisNameWidget: Text('hour'),
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 36,
            interval: xLineStep,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 25,
            interval: yLineStep,
          ),
        ),
      ),
        borderData: FlBorderData(
          show: true,
          border: const Border(left: BorderSide(color: Colors.transparent)),
        ),
        gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        drawVerticalLine: false,
        horizontalInterval: yLineStep,
        getDrawingHorizontalLine: (v){
          return const FlLine(
            color: Colors.white60,
            strokeWidth: .5,
            dashArray: [3,5]
          );
        }
      )
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,color: Colors.white
    );

    String text;

    if(value == yMinValue || value == yMaxValue){
      text = '';
    }
    else {
      text = '${value.toInt().toString()} ';
    }

    return Text(text, style: style, textAlign: TextAlign.right);
  }
  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    /// value: minX  to  maxX
    /*String text = '';

    if(value >= 1.0){
      text = value.ceil().toString().replaceFirst('.0', '');
    }*/

    var itm = bottomSteps[value.toInt()];

    if(itm == null){
      return const SizedBox();
    }

    itm = DateHelper.utcToLocal(itm);

    Widget view = UnconstrainedBox(
      child: CustomCard(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 0.7, vertical: 0.3),
        radius: 4,
        child: Column(
          children: [
            Text(itm.hour.toString().padLeft(2, '0'))
                .color(Colors.black).bold(),
            Text(itm.minute.toString().padLeft(2, '0'))
                .color(Colors.black).bold(),
          ],
        ),
      ),
    );

    return view;
    /*
    SideTitleWidget(
      axisSide: meta.axisSide,
      angle: 0,
      space: 4, // top padding
      fitInside: SideTitleFitInsideData.fromTitleMeta(meta, enabled: true, distanceFromEdge: 4),
      child: view,
    )
     */
  }

  /*void prepareBottomTexts(DateTime from){
    from = DateHelper.utcToLocal(from);

    if(chartDim == ChartDimType.day){
      from = from.add(const Duration(hours: 3));
      bottomTexts.add(' ');

      for(int i=0; i<8; i++){
        int h = from.hour;
        bottomTexts.add('$h"');
        from = from.add(const Duration(hours: 3));
      }
    }
  }*/

  void prepareMinMaxAndDots(DateTime base) {
    dots.clear();
    bottomSteps.clear();

    if(dataList.isEmpty){
      yMinValue = 0;
      yMaxValue = 1;
      yLineStep = 1;
      xMinValue = 0;
      xMaxValue = 1;
      xLineStep = 1;
      return;
    }

    yMinValue = MathHelper.clearToDouble(dataList[0].data);
    yMaxValue = MathHelper.clearToDouble(dataList[0].data);

    xMaxValue = 24* (60/5)+4; // 4 is for padding in right

    {/// first dot
      final date = dataList[0].hardwareDate!;
      final difDur = DateHelper.difference(base, date);
      /// 24*60 = 1440 minutes
      //old: 1440/8 = 180 x-step distance  if x-step be 8
      /// 1440/8 = 180 x-step distance
      final d = FlSpot(difDur.inMinutes / 5, yMinValue);
      dots.add(d);

      bottomSteps[difDur.inMinutes ~/ 5] = date;
    }

    for(int i=1; i< dataList.length; i++){
      final date = dataList[i].hardwareDate!;
      final difDur = DateHelper.difference(base, date);

      double v = MathHelper.clearToDouble(dataList[i].data);

      final d = FlSpot(difDur.inMinutes/5, v);
      dots.add(d);
      bottomSteps[difDur.inMinutes ~/ 5] = date;

      if(v > yMaxValue){
        yMaxValue = v;
      }
      else if(v < yMinValue) {
        yMinValue = v;
      }
    }

    double diff = yMaxValue - yMinValue;

    if(diff < 8){
      yLineStep = 1;
      yMinValue -= dataList.length < 2?  4 : 1;
      yMaxValue += dataList.length < 2?  4 : 1;
    }
    else {
      yMinValue -= 1;
      yMaxValue += 1;
      diff = yMaxValue - yMinValue;
      yLineStep = diff / 6;
    }
  }

  void onSettingsIconClick(BuildContext ctx) {
    void rename() async {
      await RouteTools.pushPage(context, RenameClientPage(clientModel: clientModel!));
      callState();
    }

    void removeFromHome(){
      HomeWidgetManager.current?.removeWidget(clientModel!.id);
    }

    void showChart(){
      widget.homeWidget.showChart = true;
      HomeWidgetManager.current!.sink(widget.homeWidget);
      HomeWidgetManager.current!.notifyUpdate();
    }

    void hideChart(){
      widget.homeWidget.showChart = false;
      HomeWidgetManager.current!.sink(widget.homeWidget);
      HomeWidgetManager.current!.notifyUpdate();
    }

    bool existInHome = HomeWidgetManager.current!.existOnHome(clientModel!.id);
    String addRemoveName = 'addToHome';
    String showHideName = 'hideChart';

    if(existInHome){
      addRemoveName = 'removeFromHome';
    }

    if(!widget.homeWidget.showChart){
      showHideName = 'showChart';
    }

    showMenu(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      position: AppPop.findPosition(ctx),
      items: [
        PopupMenuItem(
            height: 30,
            onTap: rename,
            child: Row(
              children: [
                const Icon(Icons.drive_file_rename_outline),
                const SizedBox(width: 20),
                Text(AppMessages.transCap('rename')).bold(),
              ],
            )
        ),

        if(!clientModel!.isVolume())
        PopupMenuItem(
            height: 30,
            onTap: widget.homeWidget.showChart? hideChart: showChart,
            child: Row(
              children: [
                const Icon(Icons.add),

                const SizedBox(width: 20),
                Text(AppMessages.trans(showHideName)).bold(),
              ],
            )
        ),

        PopupMenuItem(
            height: 30,
            onTap: existInHome? removeFromHome: null,
            child: Row(
              children: [
                const Icon(Icons.add),

                const SizedBox(width: 20),
                Text(AppMessages.trans(addRemoveName)).bold(),
              ],
            )
        ),
      ],
    );
  }

  void onNewDataListener(UpdaterGroupId p1) {
    prepareLastModel();
    prepareDataList();
  }

  void requestNewData() {
    final c = widget.homeWidget.getClient();

    if(c != null) {
      ClientDataManager.requestNewDataFor(c.id);
    }
  }

  void onReConnectNet({data}) {
    requestNewData();
  }

  void sendSwitchState(bool state) async {
    final x = await ClientDataManager.requestChangeSwitch(lastDataModel!, state);

    if(!x){
      if(lastDataModel!.isVolumeActive()) {
        lastDataModel!.data = '0';
      }
      else {
        lastDataModel!.data = '1';
      }

      callState();

      if(mounted){
        AppSnack.showError(context, AppMessages.errorCommunicatingServer);
      }
    }
  }

  void onShowFullScreenClick() {
    print('hhhh');
    RouteTools.pushPage(context, FullChartPage(homeWidget: widget.homeWidget));
  }
}
