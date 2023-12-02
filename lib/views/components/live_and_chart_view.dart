import 'package:app/managers/client_data_manager.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/models/client_data_model.dart';
import 'package:app/structures/models/green_client_model.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/widgets/colored_space.dart';
import 'package:iris_tools/widgets/custom_card.dart';

typedef OnSettingsClick = void Function(BuildContext context, GreenClientModel model);
///------------------------------------------------------
class LiveAndChartView extends StatefulWidget {
  final GreenClientModel clientModel;
  final bool showLoading;

  final OnSettingsClick? onSettingsClick;

  // ignore: prefer_const_constructors_in_immutables
  LiveAndChartView({
    super.key,
    required this.clientModel,
    this.showLoading = true,
    this.onSettingsClick,
  });

  @override
  State createState() => _LiveAndChartViewState();
}
///=============================================================================
class _LiveAndChartViewState extends StateSuper<LiveAndChartView> {
  ClientDataModel? dataModel;

  @override
  void initState(){
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ClientDataManager.fetchLastData(widget.clientModel.id, false).then((value) {
        if(value is ClientDataModel){
          dataModel = value;
          callState();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print('>>>>>>>>>>. idx: idx');
    if(dataModel == null && !widget.showLoading){
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
                              if(dataModel == null){
                                return const CircularProgressIndicator(color: Colors.white,);
                              }

                              return Text(dataModel!.data.toString())
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
                            Text(dataModel?.lastConnectionTime()?? '-')
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
                            if(dataModel == null){
                              return const SizedBox(
                                width: 100,
                                  child: UnconstrainedBox(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                              );
                            }

                            return const SizedBox();
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
        spots: [
          const FlSpot(10, 5),
          const FlSpot(10, 8),
          const FlSpot(10, 22),
          const FlSpot(10, 30),
        ])
    );

    return LineChartData(
      backgroundColor: Colors.yellow,
      lineBarsData: bars,
    );
  }

  void onSettingsIconClick(BuildContext ctx) {
    widget.onSettingsClick?.call(ctx, widget.clientModel);
  }
}
