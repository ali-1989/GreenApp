import 'dart:async';

import 'package:app/services/session_service.dart';
import 'package:app/structures/enums/app_events.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/system/extensions.dart';
import 'package:iris_db/iris_db.dart';
import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_tools/modules/stateManagers/updater_state.dart';

import 'package:app/structures/enums/updater_group.dart';
import 'package:app/structures/models/green_mind_model.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_db.dart';

class GreenMindManager {
	GreenMindManager._();

	static final List<GreenMindModel> _itemList = [];
	static bool _isInit = false;
	static Timer? _refreshTimer;

	static List<GreenMindModel> get items => _itemList;
	static Future init() async {
		if(_isInit){
			return true;
		}

		_isInit = true;
		EventNotifierService.addListener(AppEvents.networkConnected, _netListener);
		fetchAll();
		requestGreenMinds();
	}

	static void _netListener({data}){
		requestGreenMinds();
	}

	static void fetchAll() async {
		final con = Conditions();
		con.add(Condition(ConditionType.DefinedNotNull)..key = Keys.id);

		final res = AppDB.db.query(AppDB.tbGreenMind, con);

		for(final x in res){
			_itemList.add(GreenMindModel.fromMap(x));
		}
	}

	static Future<bool> sink(dynamic greenMind) async {
		if(greenMind is GreenMindModel){
			greenMind = greenMind.toMap();
		}

		final con = Conditions();
		con.add(Condition()..key = Keys.id .. value = greenMind[Keys.id]);

		final res = await AppDB.db.insertOrUpdate(AppDB.tbGreenMind, greenMind, con);

		return res > -1;
	}

	static GreenMindModel? findById(int id){
		return _itemList.firstWhereSafe((element) => element.id == id);
	}

	static void addGreenMind(dynamic greenMind, {bool notify = true}){
		if(greenMind is Map){
			greenMind = GreenMindModel.fromMap(greenMind);
		}

		final old = findById(greenMind.id);

		if(old != null){
			old.matchBy(greenMind);
		}
		else {
			_itemList.add(greenMind);
		}

		sink(greenMind);

		if(notify) {
			notifyUpdate();
		}
	}

	static void addGreenMinds(List<Map> mapList){
		for(final x in mapList){
			addGreenMind(x, notify: false);
		}

		notifyUpdate();
	}

	static void notifyUpdate(){
		UpdaterController.updateByGroup(UpdaterGroup.greenMindListUpdate);
	}

	static void newGreenMindFromWs(dynamic data){
		if(data is Map<String, dynamic>) {
			addGreenMind(GreenMindModel.fromMap(data));
		}

		if(data is List) {
			final gList = data.map((e) => e as Map<String, dynamic>).toList();
			addGreenMinds(gList);
		}
	}

	static Requester requestGreenMinds(){
		final requester = Requester();

		requester.httpRequestEvents.onStatusOk = (res, response) async {
			final data = response[Keys.data];

			if(data is List){
				final corList = data.map<Map>((e) => e as Map).toList();
				addGreenMinds(corList);
			}
		};

		final js = <String, dynamic>{};
		js[Keys.request] = 'get_green_minds';
		js[Keys.requesterId] = SessionService.getLastLoginUserId();
		js[Keys.userId] = SessionService.getLastLoginUserId();

		requester.bodyJson = js;
		requester.prepareUrl();
		requester.request();

		return requester;
	}

	static Future<bool> requestReNameGreenMind(GreenMindModel greenMind, String caption){
		final requester = Requester();
		final Completer<bool> ret = Completer();

		requester.httpRequestEvents.onStatusOk = (res, response) async {
			greenMind.caption = caption;
			sink(greenMind);
			ret.complete(true);
		};

		requester.httpRequestEvents.onFailState = (res, response) async {
			ret.complete(false);
		};

		final js = <String, dynamic>{};
		js[Keys.request] = 'rename_green_mind';
		js[Keys.requesterId] = SessionService.getLastLoginUserId();
		js['caption'] = caption;
		js['mind_id'] = greenMind.id;

		requester.bodyJson = js;
		requester.prepareUrl();
		requester.request();

		return ret.future;
	}

  static void startRefreshGreenMindTimer() {
		if(_refreshTimer == null || !_refreshTimer!.isActive){
			_refreshTimer = Timer.periodic(const Duration(seconds: 29), _refreshGreenMindFn);
			requestGreenMinds();
		}
	}

	static void stopRefreshGreenMindTimer() {
		if(_refreshTimer != null && _refreshTimer!.isActive){
			_refreshTimer?.cancel();
			_refreshTimer = null;
		}
	}

	static void _refreshGreenMindFn(Timer _){
		requestGreenMinds();
	}
}
