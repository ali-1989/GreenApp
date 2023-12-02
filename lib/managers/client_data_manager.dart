import 'dart:async';

import 'package:app/managers/green_client_manager.dart';
import 'package:app/services/session_service.dart';
import 'package:app/structures/models/client_data_model.dart';
import 'package:app/system/extensions.dart';
import 'package:iris_db/iris_db.dart';
import 'package:iris_tools/api/helpers/databaseHelper.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/modules/stateManagers/updater_state.dart';

import 'package:app/structures/enums/updater_group.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/green_child_model.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_db.dart';

/// clients => Sensors and switches

class ClientDataManager {
	ClientDataManager._();

	static bool _isInit = false;

	static void init() {
		if(_isInit){
			return;
		}

		_isInit = true;
	}

	static void dataFromWs(String userId, List<Map> list){
		addDataList(list);
	}
	///---------------------------------------------------------------------------
	static final List<ClientDataModel> _itemList = [];
	static List<ClientDataModel> get items => _itemList;

	static Future<void> fetchFor(int clientId, DateTime from, {DateTime? to}) async {
		final con = Conditions();
		con.add(Condition(ConditionType.EQUAL)..key = 'client_id'..value = clientId);
		con.add(Condition(ConditionType.IsAfterTs)..key = 'time_ts'..value = DateHelper.toTimestamp(from));

		if(to != null) {
			con.add(Condition(ConditionType.IsBeforeTs)..key = 'time_ts'..value = DateHelper.toTimestamp(to));
		}
		final res = AppDB.db.query(AppDB.tbClientData, con);

		for(final x in res){
			_itemList.add(ClientDataModel.fromMap(x));
		}
	}

	static ClientDataModel? getVolumeById(int clientId){
		return _itemList.firstWhereSafe((element) => element.clientId == clientId);
	}

	static Future<ClientDataModel?> fetchLastData(int clientId, bool notify) async {
		final con = Conditions();
		con.add(Condition()..key = 'client_id'..value = clientId);

		int sort(JSON json1, JSON json2){
			final d1 = json1['time_ts'];
			final d2 = json2['time_ts'];

			return DateHelper.compareDatesTs(d1.value, d2.value);
		}

		final res = AppDB.db.queryFirst(AppDB.tbClientData, con, orderBy: sort);

		if(res != null){
			addData(res, notify: notify);
			return ClientDataModel.fromMap(res);
		}

		return null;
	}

	static Future<bool> sink(dynamic data) async {
		final Map<String, dynamic> map;

		if(data is ClientDataModel){
			map = data.toMap();
		}
		else {
			map = data;
		}

		bool isVolume = await GreenClientManager.isVolume(map['client_id']);

		if(isVolume){
			final con = Conditions();
			con.add(Condition()..key = 'client_id' .. value = map['client_id']);

			final res = await AppDB.db.insertOrUpdate(AppDB.tbClientData, map, con);

			return res > -1;
		}
		else {
			final con = Conditions();
			con.add(Condition()..key = 'client_id' .. value = map['client_id']);
			con.add(Condition()..key = 'data' .. value = map['data']);
			con.add(Condition()..key = 'time_ts' .. value = map['time_ts']);

			final res = await AppDB.db.insertOrUpdate(AppDB.tbClientData, map, con);

			return res > -1;
		}
	}

	static ClientDataModel? findBy(int clientId, String data, DateTime? time) {
		final x = List.unmodifiable(_itemList);

		for(final i in x){
			if(i.clientId == clientId){
				if(i.isVolume()){
					return i;
				}

				if(i.data == data && i.hardwareDate == time){
					return i;
				}
			}
		}

		return null;
	}

	static void addData(dynamic obj, {bool notify = true}) {
		ClientDataModel cData;

		if(obj is Map){
			cData = ClientDataModel.fromMap(obj);
		}
		else {
			cData = obj;
		}

		final old = findBy(cData.clientId, cData.data, cData.hardwareDate);

		if(old == null){
			_itemList.add(cData);
		}
		else {
			old.matchBy(cData);
		}

		sink(cData);

		if(notify) {
			notifyUpdate(cData);
		}
	}

	static void addDataList(List<Map> mapList){
		for(final x in mapList){
			addData(x, notify: false);
		}

		notifyUpdate(null);
	}

	static void notifyUpdate(ClientDataModel? model){
		UpdaterController.updateByGroup(UpdaterGroup.greenClientUpdate, data: model);
	}

	static Future<Requester> requestData(GreenChildModel childModel) async {
		final requester = Requester();

		requester.httpRequestEvents.onStatusOk = (res, response) async {
			final data = response[Keys.data];

			if(data is List){
				final corList = data.map<Map>((e) => e as Map).toList();
				addDataList(corList);
			}
		};

		final lastModel = await fetchLastData(childModel.id, false);
		DateTime lastDate = lastModel?.hardwareDate?? DateTime.now();

		final js = <String, dynamic>{};
		js[Keys.request] = 'get_client_data';
		js[Keys.requesterId] = SessionService.getLastLoginUserId();
		js['child_id'] = childModel.id;
		js['last_date'] = DateHelper.toTimestampNullable(lastDate);

		requester.bodyJson = js;
		requester.prepareUrl();
		requester.request();

		return requester;
	}
}
