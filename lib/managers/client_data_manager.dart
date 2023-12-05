import 'dart:async';

import 'package:app/managers/green_client_manager.dart';
import 'package:app/managers/green_mind_manager.dart';
import 'package:app/services/session_service.dart';
import 'package:app/structures/models/client_data_model.dart';
import 'package:app/system/extensions.dart';
import 'package:iris_db/iris_db.dart';
import 'package:iris_tools/api/helpers/databaseHelper.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/modules/stateManagers/updater_state.dart';

import 'package:app/structures/enums/updater_group.dart';
import 'package:app/structures/middleWares/requester.dart';
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
		addDataList(list, true);
	}

	static final List<ClientDataModel> _itemList = [];
	static List<ClientDataModel> get items => _itemList;

	static Future<List<ClientDataModel>> fetchFor(int clientId, DateTime from, {DateTime? to}) async {
		final con = Conditions();
		con.add(Condition(ConditionType.EQUAL)..key = 'client_id'..value = clientId);
		con.add(Condition(ConditionType.IsAfterTs)..key = 'time_ts'..value = DateHelper.toTimestamp(from));

		if(to != null) {
			con.add(Condition(ConditionType.IsBeforeTs)..key = 'time_ts'..value = DateHelper.toTimestamp(to));
		}
		final res = AppDB.db.query(AppDB.tbClientData, con);

		List<ClientDataModel> result = [];

		for(final x in res){
			final i = ClientDataModel.fromMap(x);
			_itemList.add(i);
			result.add(i);
		}

		return result;
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

			return DateHelper.compareDatesTs(d2.value, d1.value);
		}

		final res = AppDB.db.queryFirst(AppDB.tbClientData, con, orderBy: sort);

		if(res != null){
			addData(res, notify: notify, withSink: false);
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

	static Future<void> addData(dynamic obj, {bool notify = true, bool withSink = true}) async {
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

		if(withSink) {
			await sink(cData);
		}

		if(notify) {
			notifyUpdate(cData);
		}
	}

	static Future<void> addDataList(List<Map> mapList, bool withSink) async {
		for(final x in mapList){
			await addData(x, notify: false, withSink: withSink);
		}

		notifyUpdate(null);
	}

	static void notifyUpdate(ClientDataModel? model){
		UpdaterController.updateByGroup(UpdaterGroup.greenClientUpdate, data: model);
	}

	static Future<Requester> requestNewDataFor(int clientId, {DateTime? from}) async {
		final requester = Requester();

		requester.httpRequestEvents.onStatusOk = (res, response) async {
			final data = response[Keys.data];

			if(data is List){
				final corList = data.map<Map>((e) => e as Map).toList();
				addDataList(corList, false);
			}
		};

		final lastModel = await fetchLastData(clientId, false);
		DateTime? lastDate = lastModel?.hardwareDate?? from;

		final js = <String, dynamic>{};
		js[Keys.request] = 'get_client_data';
		js[Keys.requesterId] = SessionService.getLastLoginUserId();
		js['client_id'] = clientId;
		js['last_date'] = DateHelper.toTimestampNullable(lastDate);

		requester.bodyJson = js;
		requester.prepareUrl();
		requester.request();

		return requester;
	}

	static Future<bool> requestChangeSwitch(ClientDataModel dataModel, bool state) async {
		final requester = Requester();
		final result = Completer<bool>();

		requester.httpRequestEvents.onFailState = (res, response) async {
			result.complete(false);
		};

		requester.httpRequestEvents.onStatusOk = (res, response) async {
			sink(dataModel);
			result.complete(true);
		};


		final client = GreenClientManager.getById(dataModel.clientId)!;
		final child = GreenMindManager.current!.findChildById(client.ownerId);
		final mind = GreenMindManager.current!.findByChildId(client.ownerId);

		final js = <String, dynamic>{};
		js[Keys.request] = 'set_switch_state';
		js[Keys.requesterId] = SessionService.getLastLoginUserId();
		js['mind_id'] = mind?.id;
		js['child_id'] = child?.id;
		js['bus'] = client.bus;
		js['client_id'] = dataModel.clientId;
		js['state'] = state;
		js['number'] = client.number;

		requester.bodyJson = js;
		requester.prepareUrl();
		requester.request();

		return result.future;
	}
}
