import 'dart:async';

import 'package:iris_db/iris_db.dart';
import 'package:iris_tools/modules/stateManagers/updater_state.dart';

import 'package:app/services/session_service.dart';
import 'package:app/structures/enums/updater_group.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/green_child_model.dart';
import 'package:app/structures/models/green_client_model.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_db.dart';

class GreenClientManager {
	GreenClientManager._();

	static final List<GreenClientModel> _itemList = [];
	static bool _isInit = false;

	static List<GreenClientModel> get items => _itemList;
	static Future init() async {
		if(_isInit){
			return true;
		}

		_isInit = true;
		//EventNotifierService.addListener(AppEvents.networkConnected, _netListener);
		fetchAll();
		//requestClientsFor();
	}

	/*static void _netListener({data}){
		requestClientsFor();
	}*/

	static void fetchAll() async {
		final con = Conditions();
		con.add(Condition(ConditionType.DefinedNotNull)..key = Keys.id);

		final res = AppDB.db.query(AppDB.tbGreenClient, con);

		for(final x in res){
			_itemList.add(GreenClientModel.fromMap(x));
		}
	}

	static Future<bool> sink(dynamic client) async {
		if(client is GreenClientModel){
			client = client.toMap();
		}

		final con = Conditions();
		con.add(Condition()..key = Keys.id .. value = client[Keys.id]);

		final res = await AppDB.db.insertOrUpdate(AppDB.tbGreenClient, client, con);

		return res > -1;
	}

	static GreenClientModel? findById(int id){
		return _itemList.firstWhereSafe((element) => element.id == id);
	}

	static List<GreenClientModel> filterForMind(int mindId){
		List<GreenClientModel> ret = [];

		for(final i in _itemList){
			if(i.mindId == mindId){
				ret.add(i);
			}
		}

		return ret;
	}

	static List<GreenClientModel> filterForChild(int childId){
		List<GreenClientModel> ret = [];

		for(final i in _itemList){
			if(i.ownerId == childId){
				ret.add(i);
			}
		}

		return ret;
	}

	static void addClient(dynamic client, {bool notify = true}){
		if(client is Map){
			client = GreenClientModel.fromMap(client);
		}

		final old = findById(client.id);

		if(old != null){
			old.matchBy(client);
		}
		else {
			_itemList.add(client);
		}

		sink(client);

		if(notify) {
			notifyUpdate(client);
		}
	}

	static void addClients(List<Map> mapList){
		for(final x in mapList){
			addClient(x, notify: false);
		}

		notifyUpdate(null);
	}

	static void notifyUpdate(GreenClientModel? model){
		UpdaterController.updateByGroup(UpdaterGroup.greenClientUpdate, stateData: model);
	}

	static void newClientFromWs(dynamic data){
		if(data is Map<String, dynamic>) {
			addClient(GreenClientModel.fromMap(data));
		}

		if(data is List) {
			final gList = data.map((e) => e as Map<String, dynamic>).toList();
			addClients(gList);
		}
	}

	static Requester requestClientsFor(GreenChildModel childModel){
		final requester = Requester();

		requester.httpRequestEvents.onStatusOk = (res, response) async {
			final data = response[Keys.data];

			if(data is List){
				final corList = data.map<Map>((e) => e as Map).toList();
				addClients(corList);
			}
		};

		final js = <String, dynamic>{};
		js[Keys.request] = 'get_clients_for';
		js[Keys.requesterId] = SessionService.getLastLoginUserId();
		js['mind_id'] = childModel.mindId;
		js['child_id'] = childModel.id;

		requester.bodyJson = js;
		requester.prepareUrl();
		requester.request();

		return requester;
	}

	static Future<bool> requestReNameClient(GreenClientModel client, String caption){
		final requester = Requester();
		final Completer<bool> ret = Completer();

		requester.httpRequestEvents.onStatusOk = (res, response) async {
			client.caption = caption;
			sink(client);
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
}
