import 'package:app/managers/client_data_manager.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/enums/chart_dim_type.dart';
import 'package:app/structures/enums/updater_group.dart';
import 'package:app/structures/models/client_data_model.dart';
import 'package:app/structures/models/green_client_model.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
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
  double hLineStep = 1;
  late ChartDimType chartDim;

  @override
  void initState(){
    super.initState();

    chartDim = widget.chartDimType;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      prepareLastModel();
      prepareDataList();
      UpdaterController.addGroupListener([UpdaterGroup.greenClientUpdate], onNewDataListener);
      ClientDataManager.requestNewDataFor(widget.clientModel.id);
    });
  }

  @override
  void dispose(){
    UpdaterController.removeGroupListener(onNewDataListener);

    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    print('>>>>>>>>>>. live chart build <<<<<<<<< ');
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

    bars.add(LineChartBarData(
      show: true,
        isCurved: true,
        color: Colors.white,
        barWidth: 1,
        preventCurveOverShooting: false,
        curveSmoothness: 0.2,
        //lineChartStepData: LineChartStepData(stepDirection: 5),
        isStepLineChart: false, //break Line, no Curve
        spots: [
          const FlSpot(1, 5),
          const FlSpot(2, 8),
          const FlSpot(4, 22),
          const FlSpot(8, 30),
        ]
      ),
    );

    return LineChartData(
      backgroundColor: AppDecoration.mainColor,
      minX: 0,
      maxX: 8,
      minY: 0,
      maxY: 30,
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
            reservedSize: maxValueInList(),
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
        horizontalInterval: 10,
        getDrawingHorizontalLine: (v){
          return const FlLine(
            color: Colors.white,
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
      fontSize: 12,
    );
    print('======== $value');
    String text;
    switch (value.toInt()) {
      case 1:
        text = '10K ';
        break;
      case 3:
        text = '30k';
        break;
      case 5:
        text = '50k';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.right);
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    /// value: 0  to  maxX

    /*String text = '';

    if(value >= 1.0){
      text = value.ceil().toString().replaceFirst('.0', '');
    }*/

    Widget view = Text(bottomTexts[MathHelper.toInt(meta.formattedValue)]);

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
    callState();
  }

  void prepareBottomTexts(DateTime from){
    from = DateHelper.utcToLocal(from);

    if(chartDim == ChartDimType.day){
      bottomTexts.add('');

      for(int i=0; i<8; i++){
        from = from.add(const Duration(hours: 3));
        int h = from.hour;
        bottomTexts.add('$h"');
      }
    }

  }

  double maxValueInList() {
    String max = dataList.reduce((value, element) {
      double v1 = MathHelper.clearToDouble(value.data);
      double v2 = MathHelper.clearToDouble(element.data);

      return v1 > v2? value : element;
    }).data;

    double res = MathHelper.clearToDouble(max);
    hLineStep = res/6;

    return res;
  }
}
