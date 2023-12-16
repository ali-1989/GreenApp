import 'package:app/managers/client_data_manager.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/enums/app_events.dart';
import 'package:app/structures/enums/chart_dim_type.dart';
import 'package:app/structures/enums/updater_group.dart';
import 'package:app/structures/models/client_data_model.dart';
import 'package:app/structures/models/green_child_model.dart';
import 'package:app/structures/models/green_client_model.dart';
import 'package:app/structures/models/green_mind_model.dart';
import 'package:app/structures/models/home_widget_model.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/modules/stateManagers/updater_state.dart';
import 'package:iris_tools/widgets/circle_bordering.dart';
import 'package:iris_tools/widgets/custom_card.dart';
import 'package:iris_tools/widgets/optionsRow/radioRow.dart';

class FullChartPage extends StatefulWidget {
  final HomeWidgetModel homeWidget;

  const FullChartPage({super.key, required this.homeWidget});

  @override
  State createState() => _FullChartPageState();
}
///=============================================================================
class _FullChartPageState extends StateSuper<FullChartPage> {
  late GreenMindModel greenMind;
  late GreenChildModel childModel;
  late GreenClientModel clientModel;
  bool isAllModelsOk = true;
  ClientDataModel? lastDataModel;
  List<ClientDataModel> dataList = [];
  double yMinValue = 0;
  double yMaxValue = 1;
  double yLineStep = 1;
  double xMinValue = 0;
  double xMaxValue = 8;
  double xLineStep = 1;
  ChartDimType chartDim = ChartDimType.day;
  List<FlSpot> dots = [];
  Map<int, DateTime> bottomSteps = {};
  bool errorOccurredInLiveData = false;
  String radioGroupValue = 'day';

  @override
  void initState(){
    super.initState();

    final gTemp = widget.homeWidget.getMind();
    final childTemp = widget.homeWidget.getChild();
    final clientTemp = widget.homeWidget.getClient();

    if(gTemp == null || childTemp == null || clientTemp == null){
      isAllModelsOk = false;
    }
    else {
      greenMind = gTemp;
      childModel = childTemp;
      clientModel = clientTemp;
    }

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
    return Scaffold(
      backgroundColor: AppDecoration.mainColor,
      body: buildBody(),
    );
  }

  Widget buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 22),
        const BackButton(color: Colors.white),

        Center(
          child: Chip(
            backgroundColor: Colors.white,
            label: Text(
                clientModel.getCaption(),
            ).color(Colors.black).bold().fsR(3),
          ),
        ),
        const SizedBox(height: 12),

        Expanded(
            child: Builder(
              builder: (_){
                if(errorOccurredInLiveData){
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(' ☹')
                            .color(Colors.white).fsR(15),

                        const Text(' ooh')
                            .color(Colors.white).fsMultiInRatio(14),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    /// live data
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                      child: CustomCard(
                          color: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Text('GreenMind: ').color(Colors.white70),
                                        Text(greenMind.getCaption())
                                            .bold().color(Colors.white),
                                      ],
                                    ),

                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Text('Device: ').color(Colors.white70),
                                        Text(childModel.getCaption())
                                            .bold().color(Colors.white),
                                      ],
                                    ),

                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Text('Update: ').color(Colors.white70),

                                        Text(lastDataModel?.lastConnectionTime()?? '-')
                                            .color(Colors.white).bold().fsR(2)
                                      ],
                                    )
                                  ],
                                ),
                              ),

                              /// number & icon
                              Row(
                                children: [
                                  /// number
                                  Builder(
                                      builder: (_){
                                        if(lastDataModel == null){
                                          return const CircularProgressIndicator(color: Colors.white);
                                        }

                                        return CircleBordering(
                                          borderColor: Colors.amber,
                                          borderWidth: 1.3,
                                          radius: 38,
                                          padding: const EdgeInsets.only(top: 3),
                                          child: Text(lastDataModel!.data.toString())
                                              .color(Colors.white).bold().fsRRatio(8),
                                        );
                                      }
                                  ),


                                  /// icon
                                  const SizedBox(width: 8),
                                  Icon(clientModel.getTypeIcon(), color: Colors.white),
                                ],
                              ),
                            ],
                          )
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                        children: [
                          RadioRow(
                            mainAxisSize: MainAxisSize.min,
                              description: const Text('DAY  ').color(Colors.white),
                              groupValue: radioGroupValue,
                              value: 'day',
                              onChanged: (v){
                                radioGroupValue = v;
                                callState();
                              }
                          ),

                          RadioRow(
                              mainAxisSize: MainAxisSize.min,
                              description: const Text('WEEK  ').color(Colors.white),
                              groupValue: radioGroupValue,
                              value: 'week',
                              onChanged: (v){
                                radioGroupValue = v;
                                callState();
                              }
                          ),

                          RadioRow(
                              mainAxisSize: MainAxisSize.min,
                              description: const Text('MONTH  ').color(Colors.white),
                              groupValue: radioGroupValue,
                              value: 'month',
                              onChanged: (v){
                                radioGroupValue = v;
                                callState();
                              }
                          ),

                          RadioRow(
                              mainAxisSize: MainAxisSize.min,
                              description: const Text('YEAR  ').color(Colors.white),
                              groupValue: radioGroupValue,
                              value: 'year',
                              onChanged: (v){
                                radioGroupValue = v;
                                callState();
                              }
                          ),
                        ],
                      ),
                    ),


                    /// chart
                    Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 250,
                              width: ws,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
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

                                          return Padding(
                                            padding: const EdgeInsets.only(right: 5.0),
                                            child: LineChart(genChartData()),
                                          );
                                        }
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                    ),
                  ],
                );
              },
            )
        ),
      ],
    );
  }

  void prepareLastModel() async {
    final last = await ClientDataManager.fetchLastData(clientModel.id, false);

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

    final list = await ClientDataManager.fetchFor(clientModel.id, from, to: to);

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

  void onNewDataListener(UpdaterGroupId p1) {
    prepareLastModel();
    prepareDataList();
  }

  void requestNewData() {
    ClientDataManager.requestNewDataFor(clientModel.id);
  }

  void onReConnectNet({data}) {
    requestNewData();
  }
}
