import 'package:iris_tools/api/converter.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import 'package:app/structures/enums/client_type.dart';
import 'package:app/system/keys.dart';

class GreenClientModel {
  String? userId;

  late int id;
  late int ownerId;
  late int number;
  ClientType type = ClientType.unKnow;
  late String bus;
  bool isRemoved = false;
  int status = 1;
  String? caption;
  DateTime? registerDate;


  GreenClientModel();

  GreenClientModel.fromMap(Map map){
    id = map[Keys.id];
    ownerId = map['owner_id'];
    number = map['number'];
    caption = map['caption'];
    bus = map['bus'];
    isRemoved = map['is_removed'];
    status = map['status'];
    type = ClientType.from(map['type']);
    registerDate = DateHelper.timestampToSystem(map['register_date']);

    userId = Converter.correctType<String>(map[Keys.userId]);
  }

  Map<String, dynamic> toMap(){
    final ret = <String, dynamic>{};
    ret[Keys.id] = id;
    ret['owner_id'] = ownerId;
    ret['number'] = number;
    ret['caption'] = caption;
    ret['bus'] = bus;
    ret['is_removed'] = isRemoved;
    ret['status'] = status;
    ret['type'] = type.serialize();
    ret['register_date'] = DateHelper.toTimestampNullable(registerDate);

    ret[Keys.userId] = userId;

    return ret;
  }

  matchBy(GreenClientModel model){
    ownerId = model.ownerId;
    number = model.number;
    caption = model.caption;
    bus = model.bus;
    type = model.type;
    status = model.status;
    isRemoved = model.isRemoved;
    registerDate = model.registerDate;
  }

  String getCaption(){
    return caption?? 'N-$number';
  }
}
