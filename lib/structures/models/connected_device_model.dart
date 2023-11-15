import 'package:iris_tools/dateSection/dateHelper.dart';

import 'package:app/system/keys.dart';

class ConnectedDeviceModel {
  late int id;
  bool state = false;
  String? name;
  DateTime? changeDate;

  ConnectedDeviceModel();

  ConnectedDeviceModel.fromMap(Map map){
    id = map[Keys.id];
    state = map['state'];
    name = map['name'];
    changeDate = DateHelper.timestampToSystem(map['change_date']);
  }

  Map<String, dynamic> toMap(){
    final ret = <String, dynamic>{};
    ret[Keys.id] = id;
    ret['state'] = state;
    ret['name'] = name;
    ret['change_date'] = DateHelper.toTimestampNullable(changeDate);

    return ret;
  }
}
