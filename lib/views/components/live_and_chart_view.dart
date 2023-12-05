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
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/modules/stateManagers/updater_state.dart';
import 'package:iris_tools/widgets/custom_card.dart';

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
  List<String> bottomTexts = [];
  double minValue = 0;
  double maxValue = 1;
  double hLineStep = 1;
  late ChartDimType chartDim;
  List<FlSpot> dots = [];
  //Timer todo. timer for update every 3 h

  @override
  void initState(){
    super.initState();

    chartDim = widget.chartDimType;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      prepareLastModel();
      prepareDataList();
      UpdaterController.addGroupListener([UpdaterGroup.greenClientUpdate], onNewDataListener);
      EventNotifierService.addListener(AppEvents.networkConnected, onReConnectNet);
      requestNewData();
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
    //print('>>>>>>>>>>. live chart build <<<<<<<<< ');
    if(lastDataModel == null && !widget.forceShowView){
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: CustomCard(
        color: Colors.black,
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: 150,
          child: Row(
            children: [
              Flexible(
                  flex: 2,
                  fit: FlexFit.tight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Center(
                        child: Builder(
                            builder: (_){
                              if(lastDataModel == null){
                                return const CircularProgressIndicator(color: Colors.white);
                              }

                              return Text(lastDataModel!.data.toString())
                                  .color(Colors.white).bold().fsRRatio(8);
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
                                  child: const Icon(Icons.settings, color: Colors.white)
                              );
                            }
                          ),
                      ),

                      Positioned(
                        bottom: 5,
                        left: 7,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.clientModel.getCaption())
                            .color(Colors.blue).bold().fsRRatio(1),
                            Text(lastDataModel?.lastConnectionTime()?? '-')
                                .color(Colors.white).fitWidthOverflow(),
                          ],
                        ),
                      ),

                      /// icon
                      Positioned(
                        bottom: 0,
                        top:0,
                        left: 7,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Icon(widget.clientModel.getTypeIcon(), color: Colors.white),
                        ),
                      ),
                    ],
                  )
              ),

              Flexible(
                  flex: 5,
                  fit: FlexFit.tight,
                  child: SizedBox.expand(
                    child: ColoredBox(
                      color: AppDecoration.differentColor,
                      child: Builder(
                          builder: (_){
                            if(lastDataModel == null){
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
                              return Center(
                                child: Text(AppMessages.transCap('noDataForChart')),
                              );
                            }

                            return LineChart(genChartData());
                          }
                      ),
                    ),
                  ),
              ),
            ],
          ),
        ),
      ),
    );
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
        spots: dots
      ),
    );

    return LineChartData(
      backgroundColor: AppDecoration.mainColor,
      minX: 0,
      maxX: 8,
      minY: minValue,
      maxY: maxValue,
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
            reservedSize: 25,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 25,
            interval: hLineStep,
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
        horizontalInterval: hLineStep,
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

    if(value == minValue || value == maxValue){
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

    Widget view = Text(bottomTexts[value.toInt()]).color(Colors.white);

    return SideTitleWidget(
      axisSide: meta.axisSide,
      angle: 0,
      space: 4, // top padding
      fitInside: SideTitleFitInsideData.fromTitleMeta(meta, enabled: true, distanceFromEdge: 4),
      child: view,
    );
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

  void prepareLastModel() async {
    final last = await ClientDataManager.fetchLastData(widget.clientModel.id, false);

    if(last is ClientDataModel){
      lastDataModel = last;
      callState();
    }
  }

  void prepareDataList() async {
    DateTime from;

    if(chartDim == ChartDimType.day){
      from = DateHelper.nowMinusUtcOffset().subtract(const Duration(hours: 24));
    }
    else if(chartDim == ChartDimType.week){
      from = DateHelper.nowMinusUtcOffset().subtract(const Duration(days: 7));
    }
    else if(chartDim == ChartDimType.month){
      from = DateHelper.nowMinusUtcOffset().subtract(const Duration(days: 30));
    }
    else {
      from = DateHelper.nowMinusUtcOffset().subtract(const Duration(days: 365));
    }

    final list = await ClientDataManager.fetchFor(widget.clientModel.id, from);

    dataList.clear();
    dataList.addAll(list);

    prepareBottomTexts(from);
    prepareMinMaxAndDots(from);

    callState();
  }

  void prepareBottomTexts(DateTime from){
    from = DateHelper.utcToLocal(from);

    if(chartDim == ChartDimType.day){

      for(int i=0; i<9; i++){
        int h = from.hour;
        bottomTexts.add('$h"');
        from = from.add(const Duration(hours: 3));
      }
    }
  }

  void prepareMinMaxAndDots(DateTime base) {
    dots.clear();

    if(dataList.isEmpty){
      minValue = 0;
      maxValue = 1;
      hLineStep = 1;
      return;
    }

    minValue = MathHelper.clearToDouble(dataList[0].data);
    maxValue = MathHelper.clearToDouble(dataList[0].data);

    {/// first dot
      final date = dataList[0].hardwareDate!;
      final difDur = DateHelper.difference(base, date);
      /// 24*60 = 1440
      /// 1440/8 = 180
      final d = FlSpot(difDur.inMinutes / 180, minValue);
      dots.add(d);
    }

    for(int i=1; i< dataList.length; i++){
      final date = dataList[i].hardwareDate!;
      final difDur = DateHelper.difference(base, date);

      double v = MathHelper.clearToDouble(dataList[i].data);

      final d = FlSpot(difDur.inMinutes/180, v);
      dots.add(d);

      if(v > maxValue){
        maxValue = v;
      }
      else if(v < minValue) {
        minValue = v;
      }
    }

    double diff = maxValue - minValue;

    if(diff < 8){
      hLineStep = 1;
      minValue -= dataList.length < 2?  4 : 1;
      maxValue += dataList.length < 2?  4 : 1;
    }
    else {
      minValue -= 1;
      maxValue += 1;
      diff = maxValue - minValue;
      hLineStep = diff / 6;
    }
  }
}
