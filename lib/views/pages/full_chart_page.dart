import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/modules/stateManagers/updater_state.dart';
import 'package:iris_tools/widgets/circle_bordering.dart';
import 'package:iris_tools/widgets/custom_card.dart';
import 'package:iris_tools/widgets/optionsRow/radioRow.dart';

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
import 'package:app/tools/app/app_sizes.dart';
import 'package:app/tools/date_tools.dart';

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
  late DateTime fromDate;
  late DateTime toDate;
  late DateTime currentDate;
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
  int currentPage = 0;
  int maxPage = 1;
  bool showArrowKeys = false;
  int dotToDotMinInterval = 30; //30mim
  late int maxPointCount;
  var currentScale = 3;
  int findPoint = 0;

  @override
  void initState(){
    super.initState();

    final gTemp = widget.homeWidget.getMind();
    final childTemp = widget.homeWidget.getChild();
    final clientTemp = widget.homeWidget.getClient();

    currentDate = DateTime.now();

    if(gTemp == null || childTemp == null || clientTemp == null){
      isAllModelsOk = false;
    }
    else {
      greenMind = gTemp;
      childModel = childTemp;
      clientModel = clientTemp;
      calcMaxXAxisMaxPoint();
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if(mounted){
        UpdaterController.addGroupListener([UpdaterGroup.greenClientUpdate], onNewDataListener);
        EventNotifierService.addListener(AppEvents.networkConnected, onReConnectNet);
        prepareLastModel();
        prepareDataList();
        requestNewData(fromDate);
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

        const SizedBox(height: 8),
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
                              onChanged: onChangeDaysRadio
                          ),

                          RadioRow(
                              mainAxisSize: MainAxisSize.min,
                              description: const Text('WEEK  ').color(Colors.white),
                              groupValue: radioGroupValue,
                              value: 'week',
                              onChanged: onChangeDaysRadio
                          ),

                          RadioRow(
                              mainAxisSize: MainAxisSize.min,
                              description: const Text('MONTH  ').color(Colors.white),
                              groupValue: radioGroupValue,
                              value: 'month',
                              onChanged: onChangeDaysRadio
                          ),

                          RadioRow(
                              mainAxisSize: MainAxisSize.min,
                              description: const Text('YEAR  ').color(Colors.white),
                              groupValue: radioGroupValue,
                              value: 'year',
                              onChanged: onChangeDaysRadio
                          ),
                        ],
                      ),
                    ),


                    Visibility(
                      visible: dataList.isNotEmpty,
                      child: SizedBox(
                        width: 200,
                        child: Slider(
                            value: currentScale.toDouble(),
                            min: 1,
                            max: 10,
                            divisions: 10,
                            onChanged: (v){
                              showLoading();
                              currentScale = v.toInt();

                              calcMaxXAxisMaxPoint(newDotToDotMinInterval: currentScale*10);
                              checkMustShowArrows(fromDate, toDate);
                              prepareDots();

                              hideLoading();
                              callState();
                            }
                        ),
                      ),
                    ),

                    Center(
                      child: Visibility(
                          visible: showArrowKeys,
                          child: Column(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: onBackWardClick,
                                    behavior: HitTestBehavior.translucent,
                                    child: const CircleBordering(
                                      borderColor: Colors.white,
                                      borderWidth: 1,
                                      radius: 35,
                                      padding: EdgeInsets.zero,
                                      child: Center(child: Icon(Icons.keyboard_arrow_left, color: Colors.white,)),
                                    ),
                                  ),

                                  Text('  ${currentPage+1} / $maxPage  ')
                                  .color(Colors.white),

                                  GestureDetector(
                                    onTap: onForwardClick,
                                    behavior: HitTestBehavior.translucent,
                                    child: const CircleBordering(
                                      borderColor: Colors.white,
                                      borderWidth: 1,
                                      radius: 35,
                                      padding: EdgeInsets.zero,
                                      child: Center(child: Icon(Icons.keyboard_arrow_right, color: Colors.white,)),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 6),
                              Text('[${DateTools.dateAndHmRelative(currentDate)}]')
                                  .color(Colors.white),
                            ],
                          ),
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
    toDate = DateHelper.nowMinusUtcOffset();

    if(chartDim == ChartDimType.day){
      fromDate = toDate.subtract(const Duration(hours: 24));
    }
    else if(chartDim == ChartDimType.week){
      fromDate = toDate.subtract(const Duration(days: 7));
    }
    else if(chartDim == ChartDimType.month){
      fromDate = toDate.subtract(const Duration(days: 30));
    }
    else {
      fromDate = toDate.subtract(const Duration(days: 365));
    }

    final list = await ClientDataManager.fetchFor(clientModel.id, fromDate, to: toDate);

    if(list.length == dataList.length){
      bool isSame = true;

      for(final l1 in list){
        bool find = false;

        for(final l2 in dataList){
          if(l1.data == l2.data && l1.hardwareDate == l2.hardwareDate){
            find = true;
            break;
          }
        }

        if(!find){
          isSame = false;
          break;
        }
      }

      if(isSame){
        return;
      }
    }

    dataList.clear();
    dataList.addAll(list);
    sortData();

    calcMinAndMaxForVertical();
    calcMaxXAxisMaxPoint();
    checkMustShowArrows(fromDate, toDate);
    prepareDots();

    callState();
  }

  LineChartData genChartData() {
    final bars = <LineChartBarData>[];

    bars.add(
      LineChartBarData(
        show: true,
        isCurved: true,
        isStepLineChart: false, //true: break Line, no Curve
        preventCurveOverShooting: false,
        preventCurveOvershootingThreshold: 0,
        color: Colors.white,
        barWidth: 1,
        curveSmoothness: 0.2,
        dotData: FlDotData(show: currentScale < 7),
        //lineChartStepData: LineChartStepData(stepDirection: 5),
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
    var itm = bottomSteps[value.toInt()];
    final temp = bottomSteps.values.toList();
    final showIndex = [0, bottomSteps.length-1, bottomSteps.length/2];

    if(itm == null){
      return const SizedBox();
    }

    bool isInList = showIndex.contains(temp.indexOf(itm));

    if(bottomSteps.length > 15 && !isInList){
      return const SizedBox();
    }

    bool moveEndItem = bottomSteps.length > 15 && isInList || bottomSteps.length < 3;
    //moveEndItem = moveEndItem && temp.indexOf(itm) >= bottomSteps.length-1;
    moveEndItem = moveEndItem && value > xMaxValue- (2*currentScale);

    Widget view = UnconstrainedBox(
      child: Transform.translate(
        offset: Offset(moveEndItem? -30: 0, 0),
        child: CustomCard(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 0.7, vertical: 0.3),
          radius: 4,
          child: Builder(
            builder: (context) {
              if(bottomSteps.length > 15 && isInList || bottomSteps.length < 3){
                return Column(
                  children: [
                    Text(DateTools.dateOnlyRelative(itm, isUtc: false))
                        .color(Colors.black).bold(),
                    Text(DateTools.hmOnlyRelative(itm, isUtc: false))
                        .color(Colors.black).bold(),
                  ],
                );
              }

              itm = DateHelper.utcToLocal(itm!);

              return Column(
                children: [
                  Text(itm!.hour.toString().padLeft(2, '0'))
                      .color(Colors.black).bold(),
                  Text(itm!.minute.toString().padLeft(2, '0'))
                      .color(Colors.black).bold(),
                ],
              );
            }
          ),
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

  void calcMinAndMaxForVertical(){
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

    for(int i=1; i< dataList.length; i++){
      double v = MathHelper.clearToDouble(dataList[i].data);

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

  void prepareDots() {
    dots.clear();
    bottomSteps.clear();

    double div = (maxPointCount * dotToDotMinInterval)/xMaxValue;

    final distance = Duration(minutes: currentPage * dotToDotMinInterval);
    currentDate = fromDate.add(distance);
    DateTime findDate = fromDate.add(distance);
    final start = findDate.add(const Duration());

    for(int i=0; i< maxPointCount; i++){
      final curDot = findDataForDate(findDate);

      findDate = findDate.add(Duration(minutes: dotToDotMinInterval));

      if(curDot == null){
        continue;
      }

      final date = curDot.hardwareDate!;
      final difDur = DateHelper.difference(start, date);
      double v = MathHelper.clearToDouble(curDot.data);
      double h = difDur.inMinutes / div;
      final d = FlSpot(h, v);

      dots.add(d);
      bottomSteps[h.toInt()] = date;
    }

    findDate = findDate.add(Duration(minutes: dotToDotMinInterval));

    while(findDate.isBefore(dataList.last.hardwareDate!)) {
      final curDot = findDataForDate(findDate);
      findDate = findDate.add(Duration(minutes: dotToDotMinInterval));

      if (curDot != null) {
        final difDur = DateHelper.difference(start, curDot.hardwareDate!);
        double v = MathHelper.clearToDouble(curDot.data);
        double h = difDur.inMinutes / div;
        final d = FlSpot(h, v);
        dots.add(d);
        break;
      }
    }

    double center = maxPointCount / 2;

    findPoint = currentPage * dotToDotMinInterval;
    findPoint += (center * dotToDotMinInterval).toInt();
  }

  void onNewDataListener(UpdaterGroupId p1) {
    prepareLastModel();
    prepareDataList();
  }

  void requestNewData(DateTime? from) {
    ClientDataManager.requestNewDataFor(clientModel.id, from: from);
  }

  void onReConnectNet({data}) {
    reDrawOnChangeRadio();
  }

  void onChangeDaysRadio(v){
    radioGroupValue = v;
    currentPage = 0;
    maxPage = 0;
    showArrowKeys = false;
    callState();

    showLoading();
    Future.delayed(const Duration(milliseconds: 300), (){
      reDrawOnChangeRadio();
      hideLoading();
    });
  }

  void reDrawOnChangeRadio(){
    if(radioGroupValue == 'week'){
      chartDim = ChartDimType.week;
    }
    else if(radioGroupValue == 'month'){
      chartDim = ChartDimType.month;
    }
    else if(radioGroupValue == 'year'){
      chartDim = ChartDimType.year;
    }
    else {
      chartDim = ChartDimType.day;
    }

    prepareDataList();
    requestNewData(fromDate);
  }

  ClientDataModel? findDataForDate(DateTime findDate) {
    for(final d in dataList){
      bool isBetween = d.hardwareDate!.isAfter(findDate);
      isBetween = isBetween
          && (d.hardwareDate!.isBefore(findDate.add(Duration(minutes: dotToDotMinInterval)))
          || d.hardwareDate! == findDate.add(Duration(minutes: dotToDotMinInterval)));

      if(isBetween){
        return d;
      }
    }

    return null;
  }

  void sortData(){
    int sort(ClientDataModel d1, ClientDataModel d2){
      return DateHelper.compareDates(d1.hardwareDate!, d2.hardwareDate!);
    }

    dataList.sort(sort);
  }

  void onForwardClick(){
    final end = toDate.subtract(Duration(minutes: dotToDotMinInterval * maxPointCount));

    if(currentDate.isBefore(end)) {
      currentPage++;
      prepareDots();
      callState();
    }
  }

  void onBackWardClick(){
    if(currentPage > 0) {
      currentPage--;
      prepareDots();
      callState();
    }
  }

  void calcMaxXAxisMaxPoint({int? newDotToDotMinInterval}) {
    if(newDotToDotMinInterval != null) {
      dotToDotMinInterval = newDotToDotMinInterval;
    }

    // 25 is width-space for a point to other
    var x = MathHelper.between(5, 100, 25, 10, dotToDotMinInterval.toDouble());
    // 40 is padding
    maxPointCount = (AppSizes.instance.appWidth-40) ~/ x;
    // 10: every 10min
    xMaxValue = (maxPointCount * (dotToDotMinInterval/10));
  }

  void checkMustShowArrows(DateTime first, DateTime last){
    final difDur = DateHelper.difference(first, last);

    maxPage = difDur.inMinutes ~/ dotToDotMinInterval;
    maxPage -= maxPointCount;
    maxPage++;
    showArrowKeys = maxPage > maxPointCount;

    currentPage = 0;
    int newMulti = currentPage * dotToDotMinInterval;
    double center = maxPointCount / 2;
    newMulti += (center * dotToDotMinInterval).toInt();

    while (currentPage < maxPage) {
      if (newMulti >= findPoint) {
        break;
      }

      currentPage++;
      newMulti = currentPage * dotToDotMinInterval;
      newMulti += (center * dotToDotMinInterval).toInt();
    }
  }
}
