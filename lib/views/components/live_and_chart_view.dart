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
import 'package:app/structures/enums/chart_dim_type.dart';
import 'package:app/structures/enums/updater_group.dart';
import 'package:app/structures/models/client_data_model.dart';
import 'package:app/structures/models/green_client_model.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_messages.dart';

typedef OnSettingsClick = void Function(BuildContext context, GreenClientModel model);
///------------------------------------------------------
class LiveAndChartView extends StatefulWidget {
  final GreenClientModel clientModel;
  final bool forceShowView;
  final OnSettingsClick? onSettingsClick;
  final ChartDimType chartDimType;

  // ignore: prefer_const_constructors_in_immutables
  LiveAndChartView({
    super.key,
    required this.clientModel,
    this.forceShowView = true,
    this.onSettingsClick,
    this.chartDimType = ChartDimType.day,
  });

  @override
  State createState() => _LiveAndChartViewState();
}
///=============================================================================
class _LiveAndChartViewState extends StateSuper<LiveAndChartView> {
  ClientDataModel? lastDataModel;
  List<ClientDataModel> dataList = [];
  double yMinValue = 0;
  double yMaxValue = 1;
  double yLineStep = 1;
  double xMinValue = 0;
  double xMaxValue = 8;
  double xLineStep = 1;
  late ChartDimType chartDim;
  List<FlSpot> dots = [];
  Map<int, DateTime> bottomSteps = {};
  bool errorOccurredInLiveData = false;
  //Timer todo. 100

  @override
  void initState(){
    super.initState();

    chartDim = widget.chartDimType;
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
    if(lastDataModel == null && !widget.forceShowView){
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: CustomCard(
        color: Colors.black,
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: 240,
          child: Column(
            children: [
              /// live data
              SizedBox(
                height: 70,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    /// number
                    Center(
                      child: Builder(
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
                              offset: const Offset(0, -6),
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
                    ),

                    /// settings icon
                    Positioned(
                      top: 7,
                      left: 7,
                      child: Builder(
                          builder: (ctx) {
                            return GestureDetector(
                                onTap: ()=> onSettingsIconClick(ctx),
                                behavior: HitTestBehavior.translucent,
                                child: const Icon(Icons.settings, color: Colors.white)
                            );
                          }
                      ),
                    ),

                    /// icon
                    Positioned(
                      top:7,
                      right: 7,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(widget.clientModel.getTypeIcon(), color: Colors.white),
                      ),
                    ),

                    /// name
                    Positioned(
                      bottom: 5,
                      left: 7,
                      child: Text(widget.clientModel.getCaption())
                          .color(Colors.blue).bold().fsRRatio(1),
                    ),

                    /// date
                    Positioned(
                      bottom: 5,
                      right: 7,
                      child: Row(
                        children: [
                          const Text('last update: ')
                              .color(Colors.grey).bold().fsR(1),

                          Text(lastDataModel?.lastConnectionTime()?? '-')
                              .color(Colors.white).bold().fsR(2),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              /// chart
              SizedBox(
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

                        return LineChart(genChartData());
                      }
                  ),
                ),
              ),
            ],
          )
        ),
      ),
    );
  }

  void prepareLastModel() async {
    final last = await ClientDataManager.fetchLastData(widget.clientModel.id, false);

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
    DateTime to = DateHelper.nowMinusUtcOffset();
    DateTime from;

    if(chartDim == ChartDimType.day){
      from = to.subtract(const Duration(hours: 24));
    }
    else if(chartDim == ChartDimType.week){
      from = to.subtract(const Duration(days: 7));
    }
    else if(chartDim == ChartDimType.month){
      from = to.subtract(const Duration(days: 30));
    }
    else {
      from = to.subtract(const Duration(days: 365));
    }

    final list = await ClientDataManager.fetchFor(widget.clientModel.id, from, to: to);

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
    widget.onSettingsClick?.call(ctx, widget.clientModel);
  }

  void onNewDataListener(UpdaterGroupId p1) {
    prepareLastModel();
    prepareDataList();
  }

  void requestNewData() {
    ClientDataManager.requestNewDataFor(widget.clientModel.id);
  }

  void onReConnectNet({data}) {
    requestNewData();
  }
}
