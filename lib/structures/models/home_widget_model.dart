import 'package:iris_tools/api/converter.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import 'package:app/managers/green_client_manager.dart';
import 'package:app/managers/green_mind_manager.dart';
import 'package:app/structures/models/green_child_model.dart';
import 'package:app/structures/models/green_client_model.dart';
import 'package:app/structures/models/green_mind_model.dart';
import 'package:app/system/keys.dart';

class HomeWidgetModel {
  late String userId;
  late int clientId;
  late int greenMindId;
  late int childId;
  late DateTime registerDate;
  int order = 0;
  bool showChart = true;

  HomeWidgetModel();

  HomeWidgetModel.fromMap(Map map){
    userId = Converter.correctType<String>(map[Keys.userId])!;
    clientId = map['client_id'];
    greenMindId = map['green_mind_id'];
    childId = map['child_id'];
    order = map['order'];
    showChart = map['show_chart'];
    registerDate = DateHelper.timestampToSystem(map['register_date'])!;
  }

  Map<String, dynamic> toMap(){
    final ret = <String, dynamic>{};
    ret[Keys.id] = userId;
    ret['client_id'] = clientId;
    ret['green_mind_id'] = greenMindId;
    ret['child_id'] = childId;
    ret['order'] = order;
    ret['show_chart'] = showChart;
    ret['register_date'] = DateHelper.toTimestampNullable(registerDate);

    return ret;
  }

  void matchBy(HomeWidgetModel model){
    userId = model.userId;
    clientId = model.clientId;
    greenMindId = model.greenMindId;
    childId = model.childId;
    order = model.order;
    showChart = model.showChart;
    registerDate = model.registerDate;
  }

  GreenClientModel? getClient() {
    return GreenClientManager.getManagerFor(userId).findById(clientId);
  }

  GreenMindModel? getMind() {
    return GreenMindManager.getManagerFor(userId).findById(greenMindId);
  }

  GreenChildModel? getChild() {
    return GreenMindManager.getManagerFor(userId).findChildById(childId);
  }

}
