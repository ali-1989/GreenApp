import 'package:iris_tools/dateSection/dateHelper.dart';

import 'package:app/structures/models/green_guide_model.dart';
import 'package:app/structures/models/green_sight_model.dart';
import 'package:app/system/keys.dart';

class GreenMindModel {
  late int id;
  late String serialNumber;
  int? firmwareVersion;
  DateTime? productDate;
  late DateTime registerDate;
  DateTime? communicationDate;
  List<GreenSightModel> sights = [];
  List<GreenGuideModel> guides = [];

  GreenMindModel();

  GreenMindModel.fromMap(Map map){
    id = map[Keys.id];
    serialNumber = map['serial_number'];
    firmwareVersion = map['firmware_version'];
    productDate = DateHelper.timestampToSystem(map['product_date']);
    registerDate = DateHelper.timestampToSystem(map['register_date'])!;
    communicationDate = DateHelper.timestampToSystem(map['communication_date']);

    List? gSights = map['sights'];
    List? gGuides = map['guides'];

    if(gSights is List){
      sights = gSights.map((e) => GreenSightModel.fromMap(e)).toList();
    }

    if(gGuides is List){
      guides = gGuides.map((e) => GreenGuideModel.fromMap(e)).toList();
    }
  }

  Map<String, dynamic> toMap(){
    final ret = <String, dynamic>{};
    ret[Keys.id] = id;
    ret['serial_number'] = serialNumber;
    ret['firmware_version'] = firmwareVersion;
    ret['product_date'] = DateHelper.toTimestampNullable(productDate);
    ret['register_date'] = DateHelper.toTimestampNullable(registerDate);
    ret['communication_date'] = DateHelper.toTimestampNullable(communicationDate);
    ret['sights'] = sights.map((e) => e.toMap());
    ret['guides'] = guides.map((e) => e.toMap());

    return ret;
  }
}
