import 'dart:async';

import 'package:app/managers/green_client_manager.dart';
import 'package:iris_db/iris_db.dart';
import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_tools/modules/stateManagers/updater_state.dart';

import 'package:app/services/session_service.dart';
import 'package:app/structures/enums/app_events.dart';
import 'package:app/structures/enums/updater_group.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/green_child_model.dart';
import 'package:app/structures/models/green_mind_model.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_cache.dart';
import 'package:app/tools/app/app_db.dart';

class GreenMindManager {
	GreenMindManager._(this.userId);

	static final List<GreenMindManager> _userHolder = [];
	static bool _isInit = false;

	static GreenMindManager getManagerFor(String userId){
		for(final kv in _userHolder){
			if(kv.userId == userId){
				return kv;
			}
		}

		final newItm = GreenMindManager._(userId);
		_userHolder.add(newItm);
		return newItm;
	}

	static GreenMindManager? get current {
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
		EventNotifierService.addListener(AppEvents.networkConnected, _netListener);
	}

	static void _netListener({data}){
		current?.requestGreenMinds();
	}

	static void newGreenMindFromWs(String userId, dynamic data){
		final cur = current;

		if(cur == null || cur.userId != userId){
			return;
		}

		if(data is Map<String, dynamic>) {
			cur.addGreenMind(data);
		}

		if(data is List) {
			final gList = data.map((e) => e as Map<String, dynamic>).toList();
			cur.addGreenMinds(gList);
		}
	}
	///---------------------------------------------------------------------------
	final String userId;
	final List<GreenMindModel> _itemList = [];
	Timer? _refreshTimer;
	List<GreenMindModel> get items => _itemList;


	Future<void> start() async {
		await fetchAll();
		requestGreenMinds();
	}

	Future<void> fetchAll() async {
		final con = Conditions();
		con.add(Condition(ConditionType.DefinedNotNull)..key = Keys.id);
		con.add(Condition(ConditionType.EQUAL)..key = Keys.userId..value = userId);

		final res = AppDB.db.query(AppDB.tbGreenMind, con);

		for(final x in res){
			_itemList.add(GreenMindModel.fromMap(x));
		}
	}

	Future<bool> sink(dynamic greenMind) async {
		final Map<String, dynamic> map;

		if(greenMind is GreenMindModel){
			map = greenMind.toMap();
		}
		else {
			map = greenMind;
		}

		map[Keys.userId] ??= userId;

		final con = Conditions();
		con.add(Condition()..key = Keys.id .. value = map[Keys.id]);

		final res = await AppDB.db.insertOrUpdate(AppDB.tbGreenMind, map, con);

		return res > -1;
	}

	GreenMindModel? findById(int id){
		return _itemList.firstWhereSafe((element) => element.id == id);
	}

	GreenMindModel? findByChildId(int childId){
		return _itemList.firstWhereSafe(
						(element)
				=> element.children.any((element) => element.id == childId));
	}

	GreenChildModel? findChildById(int childId){
		for(final x in _itemList){
			for(final x2 in x.children){
				if(x2.id == childId){
					return x2;
				}
			}
		}

		return null;
	}

	void addGreenMind(dynamic obj, {bool notify = true}){
		GreenMindModel greenMind;

		if(obj is Map){
			greenMind = GreenMindModel.fromMap(obj);
		}
		else {
			greenMind = obj;
		}

		greenMind.userId ??= userId;

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

	void addGreenMinds(List<Map> mapList){
		for(final x in mapList){
			addGreenMind(x, notify: false);
		}

		notifyUpdate();
	}

	void notifyUpdate(){
		UpdaterController.updateByGroup(UpdaterGroup.greenMindUpdate);
	}

	Future<void> removeUnNeedGreenMinds(List<int> ids){
		final con = Conditions();
		con.add(Condition()..key=Keys.userId..value = userId);
		con.add(Condition(ConditionType.NotIn)..key='id'..value = ids);

		print('777777777777777777777777777777777');
		AppDB.db.logRows(AppDB.tbGreenMind);
		final res = AppDB.db.delete(AppDB.tbGreenMind, con);
		Future.delayed(Duration(seconds: 2), (){
			print('777777777777777777777777777777777 2');
			AppDB.db.logRows(AppDB.tbGreenMind);
		});
		return res;

	}

	Requester? requestGreenMinds(){
		if(!AppCache.canCallMethodAgain('requestGreenMinds')){
			return null;
		}

		final requester = Requester();

		requester.httpRequestEvents.onStatusOk = (res, response) async {
			final data = response[Keys.data];

			if(data is List){
				final corList = data.map<Map>((e) => e as Map).toList();

				List<int> ids = [];
				for(final x in corList){
					ids.add(x['id']);
				}

				await removeUnNeedGreenMinds(ids);
				addGreenMinds(corList);
			}
		};

		final js = <String, dynamic>{};
		js[Keys.request] = 'get_green_minds';
		js[Keys.requesterId] = userId;
		js[Keys.userId] = userId;

		requester.bodyJson = js;
		requester.prepareUrl();
		requester.request();

		return requester;
	}

	Future<bool> requestReNameGreenMind(GreenMindModel greenMind, String caption){
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
		js[Keys.requesterId] = userId;
		js['caption'] = caption;
		js['mind_id'] = greenMind.id;

		requester.bodyJson = js;
		requester.prepareUrl();
		requester.request();

		return ret.future;
	}

  Future<bool> requestReNameGreenChild(GreenChildModel greenChild, String caption){
		final requester = Requester();
		final Completer<bool> ret = Completer();

		requester.httpRequestEvents.onStatusOk = (res, response) async {
			greenChild.caption = caption;
			sink(findById(greenChild.mindId));
			ret.complete(true);
		};

		requester.httpRequestEvents.onFailState = (res, response) async {
			ret.complete(false);
		};

		final js = <String, dynamic>{};
		js[Keys.request] = 'rename_green_child';
		js[Keys.requesterId] = userId;
		js['caption'] = caption;
		js['child_id'] = greenChild.id;

		requester.bodyJson = js;
		requester.prepareUrl();
		requester.request();

		return ret.future;
	}

  void startRefreshGreenMindTimer() {
		if(_refreshTimer == null || !_refreshTimer!.isActive){
			_refreshTimer = Timer.periodic(const Duration(seconds: 29), _refreshGreenMindFn);
			requestGreenMinds();
		}
	}

	void stopRefreshGreenMindTimer() {
		if(_refreshTimer != null && _refreshTimer!.isActive){
			_refreshTimer?.cancel();
			_refreshTimer = null;
		}
	}

	void _refreshGreenMindFn(Timer _){
		requestGreenMinds();
	}
	///----- static --------------------------------------------------------------
	static Future<bool> requestChangeToAddDeviceMode(int mindId){
		final requester = Requester();
		final Completer<bool> ret = Completer();

		requester.httpRequestEvents.onStatusOk = (res, response) async {
			ret.complete(true);
		};

		requester.httpRequestEvents.onFailState = (res, response) async {
			ret.complete(false);
		};

		final js = <String, dynamic>{};
		js[Keys.request] = 'add_new_device_state_for_hardware';
		js[Keys.requesterId] = SessionService.getLastLoginUserId();
		js['mind_id'] = mindId;

		requester.bodyJson = js;
		requester.prepareUrl();
		requester.request();

		return ret.future;
	}

  static void updateChildren(String userId, List<Map<dynamic, dynamic>> children) {
		final m = getManagerFor(userId);
		
		for(final map in children){
			final child = GreenChildModel.fromMap(map);
			m.findById(child.mindId)?.matchChild(child);
		}
	}

  static Future<void> deleteUserFootMark(String userId) async {
		final m = getManagerFor(userId);
		Set<int> mindId = {};
		Set<int> childrenId = {};

		for(final x in m._itemList){
			mindId.add(x.id);

			for(final c in x.children){
				childrenId.add(c.id);
			}
		}

		final con = Conditions();
		con.add(Condition()..key = Keys.userId..value = userId);
		await AppDB.db.delete(AppDB.tbGreenMind, con);

		_userHolder.removeWhere((element) => element.userId == userId);

		await GreenClientManager.deleteUserFootMark(userId);
	}
}
