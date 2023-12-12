import 'dart:async';

import 'package:iris_db/iris_db.dart';
import 'package:iris_tools/modules/stateManagers/updater_state.dart';

import 'package:app/services/session_service.dart';
import 'package:app/structures/enums/client_type.dart';
import 'package:app/structures/enums/updater_group.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/green_child_model.dart';
import 'package:app/structures/models/green_client_model.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_db.dart';

/// clients => Sensors and switches

class GreenClientManager {
	GreenClientManager._(this.userId);

	static final List<GreenClientManager> _userHolder = [];
	static bool _isInit = false;

	static GreenClientManager getManagerFor(String userId){
		for(final kv in _userHolder){
			if(kv.userId == userId){
				return kv;
			}
		}

		final newItm = GreenClientManager._(userId);
		_userHolder.add(newItm);
		return newItm;
	}

	static GreenClientManager? get current {
		final cUserId = SessionService.getLastLoginUserId();

		if(cUserId == null){
			return null;
		}

		return getManagerFor(cUserId);
	}

	static void init() {
		if(_isInit){
			return;
		}

		_isInit = true;
	}

	static void dataFromWs(String userId, List<Map> clients, bool notify){
		final cur = current;

		if(cur == null || cur.userId != userId){
			return;
		}

		current?.addClients(clients, notify);
	}
	///---------------------------------------------------------------------------
	final String userId;
	final List<GreenClientModel> _itemList = [];
	List<GreenClientModel> get items => _itemList;

	Future<void> start() async {
		await fetchAll();
	}

	Future<void> fetchAll() async {
		final con = Conditions();
		con.add(Condition(ConditionType.DefinedNotNull)..key = Keys.id);
		con.add(Condition(ConditionType.EQUAL)..key = Keys.userId..value = userId);

		final res = AppDB.db.query(AppDB.tbGreenClient, con);

		for(final x in res){
			_itemList.add(GreenClientModel.fromMap(x));
		}
	}

	static Future<bool> sink(dynamic client, String userId) async {
		final Map<String, dynamic> map;

		if(client is GreenClientModel){
			map = client.toMap();
		}
		else {
			map = client;
		}

		map[Keys.userId] ??= userId;

		final con = Conditions();
		con.add(Condition()..key = Keys.id .. value = map[Keys.id]);

		final res = await AppDB.db.insertOrUpdate(AppDB.tbGreenClient, map, con);

		return res > -1;
	}

	GreenClientModel? findById(int id){
		return _itemList.firstWhereSafe((element) => element.id == id);
	}

	List<GreenClientModel> filterForChild(int childId){
		List<GreenClientModel> ret = [];

		for(final i in _itemList){
			if(i.ownerId == childId){
				ret.add(i);
			}
		}

		return ret;
	}

	void addClient(dynamic obj, {bool notify = true}){
		GreenClientModel gClient;

		if(obj is Map){
			gClient = GreenClientModel.fromMap(obj);
		}
		else {
			gClient = obj;
		}

		gClient.userId ??= userId;

		final old = findById(gClient.id);

		if(old != null){
			old.matchBy(gClient);
		}
		else {
			_itemList.add(gClient);
		}

		sink(gClient, userId);

		if(notify) {
			notifyUpdate(gClient);
		}
	}

	void addClients(List<Map> mapList, bool notify){
		for(final x in mapList){
			addClient(x, notify: false);
		}

		if(notify) {
			notifyUpdate(null);
		}
	}

	void notifyUpdate(GreenClientModel? model){
		UpdaterController.updateByGroup(UpdaterGroup.greenClientUpdate, data: model);
	}

	Requester requestClientsFor(GreenChildModel childModel){
		final requester = Requester();

		requester.httpRequestEvents.onStatusOk = (res, response) async {
			final data = response[Keys.data];

			if(data is List){
				final corList = data.map<Map>((e) => e as Map).toList();
				addClients(corList, true);
			}
		};

		final js = <String, dynamic>{};
		js[Keys.request] = 'get_clients_for';
		js[Keys.requesterId] = userId;
		js['mind_id'] = childModel.mindId;
		js['child_id'] = childModel.id;

		requester.bodyJson = js;
		requester.prepareUrl();
		requester.request();

		return requester;
	}

	static Future<bool> requestReNameClient(GreenClientModel client, String caption, String userId){
		final requester = Requester();
		final Completer<bool> ret = Completer();

		requester.httpRequestEvents.onStatusOk = (res, response) async {
			client.caption = caption;
			sink(client, userId);
			ret.complete(true);
		};

		requester.httpRequestEvents.onFailState = (res, response) async {
			ret.complete(false);
		};

		final js = <String, dynamic>{};
		js[Keys.request] = 'rename_green_client';
		js[Keys.requesterId] = SessionService.getLastLoginUserId();
		js['caption'] = caption;
		js['client_id'] = client.id;

		requester.bodyJson = js;
		requester.prepareUrl();
		requester.request();

		return ret.future;
	}

	static GreenClientModel? getById(int id){
		for(final u in _userHolder){
			for(final c in u.items){
				if(c.id == id){
					return c;
				}
			}
		}

		return null;
	}

  static Future<bool> isVolume(int clientId) async {
		final itm = getById(clientId);

		if(itm != null){
			return itm.type == ClientType.volume;
		}

		final cons = Conditions();
		cons.add(Condition()..key = 'client_id'..value = clientId);

		final res = await AppDB.db.queryFirst(AppDB.tbGreenClient, cons);

		if(res != null){
			return GreenClientModel.fromMap(res).type == ClientType.volume;
		}

		return false;
	}
}
