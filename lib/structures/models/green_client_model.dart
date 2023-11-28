import 'package:iris_tools/dateSection/dateHelper.dart';

import 'package:app/structures/enums/client_type.dart';
import 'package:app/system/keys.dart';

class GreenClientModel {
  late int id;
  int? mindId;
  late int ownerId;
  late int number;
  ClientType type = ClientType.unKnow;
  late String bus;
  String? caption;
  DateTime? registerDate;


  GreenClientModel();

  GreenClientModel.fromMap(Map map){
    id = map[Keys.id];
    mindId = map['mind_id'];
    ownerId = map['owner_id'];
    number = map['number'];
    caption = map['caption'];
    bus = map['bus'];
    type = ClientType.from(map['type']);
    registerDate = DateHelper.timestampToSystem(map['register_date']);
  }

  Map<String, dynamic> toMap(){
    final ret = <String, dynamic>{};
    ret[Keys.id] = id;
    ret['mind_id'] = mindId;
    ret['owner_id'] = ownerId;
    ret['number'] = number;
    ret['caption'] = caption;
    ret['bus'] = bus;
    ret['type'] = type.serialize();
    ret['register_date'] = DateHelper.toTimestampNullable(registerDate);

    return ret;
  }

  matchBy(GreenClientModel model){
    mindId = model.mindId;
    ownerId = model.ownerId;
    number = model.number;
    caption = model.caption;
    bus = model.bus;
    type = model.type;
    registerDate = model.registerDate;
  }

  String getCaption(){
    return caption?? 'N-$number';
  }

}
