import 'package:app/system/keys.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

class GreenMindModel {
  late int id;
  late String serialNumber;
  int? firmwareVersion;
  DateTime? productDate;
  late DateTime registerDate;
  DateTime? communicationDate;

  GreenMindModel();

  GreenMindModel.fromMap(Map map){
    id = map[Keys.id];
    serialNumber = map['serial_number'];
    firmwareVersion = map['firmware_version'];
    productDate = DateHelper.timestampToSystem(map['product_date']);
    registerDate = DateHelper.timestampToSystem(map['register_date'])!;
    communicationDate = DateHelper.timestampToSystem(map['communication_date']);
  }

  Map<String, dynamic> toMap(){
    final ret = <String, dynamic>{};
    ret[Keys.id] = id;
    ret['serial_number'] = serialNumber;
    ret['firmware_version'] = firmwareVersion;
    ret['product_date'] = DateHelper.toTimestampNullable(productDate);
    ret['register_date'] = DateHelper.toTimestampNullable(registerDate);
    ret['communication_date'] = DateHelper.toTimestampNullable(communicationDate);

    return ret;
  }
}
