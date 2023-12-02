import 'package:app/managers/green_client_manager.dart';
import 'package:app/structures/enums/client_type.dart';
import 'package:app/tools/date_tools.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

class ClientDataModel {
  late int clientId;
  late String data;
  DateTime? hardwareDate;
  late DateTime receiveDate;
  /// this field is not in Table and obtain with JOIN.
  ClientType type = ClientType.unKnow;

  ClientDataModel();

  ClientDataModel.fromMap(Map map){
    clientId = map['client_id'];
    data = map['data'];
    hardwareDate = DateHelper.timestampToSystem(map['time_ts']);
    receiveDate = DateHelper.timestampToSystem(map['receive_date'])!;
    type = ClientType.from(map['type']);
  }

  Map<String, dynamic> toMap(){
    final ret = <String, dynamic>{};
    ret['client_id'] = clientId;
    ret['data'] = data;
    ret['time_ts'] = DateHelper.toTimestampNullable(hardwareDate);
    ret['receive_date'] = DateHelper.toTimestampNullable(receiveDate);
    ret['type'] = type.serialize();

    return ret;
  }

  void matchBy(ClientDataModel model){
    clientId = model.clientId;
    data = model.data;
    hardwareDate = model.hardwareDate;
    receiveDate = model.receiveDate;
    type = model.type;
  }

  bool isVolume() {
    return type == ClientType.volume;
  }

  Future<bool> isVolumeInParentTable() {
    return GreenClientManager.isVolume(clientId);
  }

  String lastConnectionTime() {
    DateTime t;

    if(type == ClientType.volume){
      t = receiveDate;
    }
    else {
      t = hardwareDate!;
    }

    if(DateHelper.isToday(t, utc: true)){
      return DateTools.hmOnlyRelative(t);
    }

    return DateTools.dateAndHmRelative(t);
  }
}
