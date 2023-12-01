import 'package:app/managers/green_client_manager.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

class ClientDataModel {
  late int clientId;
  late String data;
  DateTime? hardwareDate;
  late DateTime receiveDate;


  ClientDataModel();

  ClientDataModel.fromMap(Map map){
    clientId = map['client_id'];
    data = map['data'];
    hardwareDate = DateHelper.timestampToSystem(map['time_ts']);
    receiveDate = DateHelper.timestampToSystem(map['receive_date'])!;
  }

  Map<String, dynamic> toMap(){
    final ret = <String, dynamic>{};
    ret['client_id'] = clientId;
    ret['data'] = data;
    ret['time_ts'] = DateHelper.toTimestampNullable(hardwareDate);
    ret['receive_date'] = DateHelper.toTimestampNullable(receiveDate);

    return ret;
  }

  void matchBy(ClientDataModel model){
    clientId = model.clientId;
    data = model.data;
    hardwareDate = model.hardwareDate;
    receiveDate = model.receiveDate;
  }

  Future<bool> isVolume() {
    return GreenClientManager.isVolume(clientId);
  }
}
