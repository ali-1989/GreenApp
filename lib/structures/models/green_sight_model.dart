import 'package:iris_tools/dateSection/dateHelper.dart';

import 'package:app/structures/models/connected_device_model.dart';
import 'package:app/system/keys.dart';

class GreenSightModel {
  late int id;
  late int mindId;
  late String serialNumber;
  int? firmwareVersion;
  DateTime? productDate;
  late DateTime registerDate;
  List<ConnectedDeviceModel> devices = [];

  GreenSightModel();

  GreenSightModel.fromMap(Map map){
    id = map[Keys.id];
    mindId = map['mind_id'];
    serialNumber = map['serial_number'];
    firmwareVersion = map['firmware_version'];
    productDate = DateHelper.timestampToSystem(map['product_date']);
    registerDate = DateHelper.timestampToSystem(map['register_date'])!;
    
    if(map['devices'] != null){
      List temp = map['devices'];
      devices = temp.map((e) => ConnectedDeviceModel.fromMap(e)).toList();
    }
  }

  Map<String, dynamic> toMap(){
    final ret = <String, dynamic>{};
    ret[Keys.id] = id;
    ret['mind_id'] = mindId;
    ret['serial_number'] = serialNumber;
    ret['firmware_version'] = firmwareVersion;
    ret['product_date'] = DateHelper.toTimestampNullable(productDate);
    ret['register_date'] = DateHelper.toTimestampNullable(registerDate);
    ret['devices'] = devices.map((e) => e.toMap());

    return ret;
  }
}
