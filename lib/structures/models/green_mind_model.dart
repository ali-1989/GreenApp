import 'package:flutter/material.dart';

import 'package:iris_tools/dateSection/dateHelper.dart';

import 'package:app/structures/enums/green_child_type.dart';
import 'package:app/structures/models/green_child_model.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/date_tools.dart';

class GreenMindModel {
  late int id;
  late String serialNumber;
  int? firmwareVersion;
  String? caption;
  DateTime? productDate;
  late DateTime registerDate;
  DateTime? communicationDate;
  List<GreenChildModel> children = [];

  GreenMindModel();

  GreenMindModel.fromMap(Map map){
    id = map[Keys.id];
    serialNumber = map['serial_number'];
    firmwareVersion = map['firmware_version'];
    caption = map['caption'];
    productDate = DateHelper.timestampToSystem(map['product_date']);
    registerDate = DateHelper.timestampToSystem(map['register_date'])!;
    communicationDate = DateHelper.timestampToSystem(map['communication_date']);

    List? childrenList = map['children'];

    if(childrenList != null && childrenList.isNotEmpty && childrenList.first != null){
      children = childrenList.map((e) => GreenChildModel.fromMap(e)).toList();
    }
  }

  Map<String, dynamic> toMap(){
    final ret = <String, dynamic>{};
    ret[Keys.id] = id;
    ret['serial_number'] = serialNumber;
    ret['firmware_version'] = firmwareVersion;
    ret['caption'] = caption;
    ret['product_date'] = DateHelper.toTimestampNullable(productDate);
    ret['register_date'] = DateHelper.toTimestampNullable(registerDate);
    ret['communication_date'] = DateHelper.toTimestampNullable(communicationDate);
    ret['children'] = children.map((e) => e.toMap()).toList();

    return ret;
  }

  matchBy(GreenMindModel model){
    caption = model.caption;
    serialNumber = model.serialNumber;
    firmwareVersion = model.firmwareVersion;
    registerDate = model.registerDate;
    productDate = model.productDate;
    communicationDate = model.communicationDate;

    children.clear();
    children.addAll(model.children);
  }

  String getCaption(){
    if(caption != null){
      return caption!;
    }

    return 'SN: $serialNumber';
  }

  Color getStatusColor() {
    DateTime lastDate = communicationDate?? registerDate;
    lastDate = DateHelper.utcToLocal(lastDate);

    if(DateHelper.isPastOf(lastDate, const Duration(seconds: 31))){
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

  int countOfGuids(){
    return children.where((e) => e.type == GreenChildType.guide).length;
  }

  int countOfSights(){
    return children.where((e) => e.type == GreenChildType.sight).length;
  }
}
