import 'package:flutter/material.dart';

import 'package:iris_tools/dateSection/dateHelper.dart';

import 'package:app/structures/enums/green_child_type.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/date_tools.dart';

class GreenChildModel {
  late int id;
  late int mindId;
  String? caption;
  late String serialNumber;
  GreenChildType type = GreenChildType.unKnow;
  int? firmwareVersion;
  int? batteryLevel;
  DateTime? productDate;
  late DateTime registerDate;
  DateTime? communicationDate;

  GreenChildModel();

  GreenChildModel.fromMap(Map map){
    id = map[Keys.id];
    mindId = map['mind_id'];
    serialNumber = map['serial_number'];
    firmwareVersion = map['firmware_version'];
    caption = map['caption'];
    batteryLevel = map['battery_level'];
    type = GreenChildType.from(map['type']);
    productDate = DateHelper.timestampToSystem(map['product_date']);
    registerDate = DateHelper.timestampToSystem(map['register_date'])!;
    communicationDate = DateHelper.timestampToSystem(map['communication_date']);
  }

  Map<String, dynamic> toMap(){
    final ret = <String, dynamic>{};
    ret[Keys.id] = id;
    ret['mind_id'] = mindId;
    ret['serial_number'] = serialNumber;
    ret['firmware_version'] = firmwareVersion;
    ret['caption'] = caption;
    ret['battery_level'] = batteryLevel;
    ret['type'] = type.serialize();
    ret['product_date'] = DateHelper.toTimestampNullable(productDate);
    ret['register_date'] = DateHelper.toTimestampNullable(registerDate);
    ret['communication_date'] = DateHelper.toTimestampNullable(communicationDate);

    return ret;
  }

  String getCaption(){
    return caption?? serialNumber;
  }

  bool isSight() {
    return type == GreenChildType.sight;
  }

  Color typeColor() {
    return isSight()? Colors.blue : Colors.pinkAccent;
  }

  Color getStatusColor() {
    DateTime lastDate = communicationDate?? registerDate;
    lastDate = DateHelper.utcToLocal(lastDate);

    if(DateHelper.isPastOf(lastDate, const Duration(hours: 6))){
      return Colors.orange;
    }

    return Colors.green;
  }

  String lastConnectionTime() {
    if(communicationDate == null){
      return '-';
    }

    if(DateHelper.isToday(communicationDate!, utc: true)){
      return DateTools.hmOnlyRelative(communicationDate);
    }

    return DateTools.dateAndHmRelative(communicationDate);
  }
}
