import 'dart:async';

import 'package:app/managers/green_client_manager.dart';
import 'package:iris_db/iris_db.dart';
import 'package:iris_tools/modules/stateManagers/updater_state.dart';

import 'package:app/services/session_service.dart';
import 'package:app/structures/enums/updater_group.dart';
import 'package:app/structures/models/green_child_model.dart';
import 'package:app/structures/models/green_mind_model.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_db.dart';

class HomeWidgetManager {
	HomeWidgetManager._(this.userId);

	static final List<HomeWidgetManager> _userHolder = [];
	static bool _isInit = false;

	static HomeWidgetManager getManagerFor(String userId){
		for(final kv in _userHolder){
			if(kv.userId == userId){
				return kv;
			}
		}

		final newItm = HomeWidgetManager._(userId);
		_userHolder.add(newItm);
		return newItm;
	}

	static HomeWidgetManager? get current {
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

	///---------------------------------------------------------------------------
	final String userId;
	final List<GreenMindModel> _itemList = [];
	List<GreenMindModel> get items => _itemList;


	Future<void> start() async {
		await fetchAll();
	}

	Future<void> fetchAll() async {
		final con = Conditions();
		con.add(Condition(ConditionType.DefinedNotNull)..key = Keys.id);
		con.add(Condition(ConditionType.EQUAL)..key = Keys.userId..value = userId);

		final res = AppDB.db.query(AppDB.tbHomeWidgets, con);

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

		final res = await AppDB.db.insertOrUpdate(AppDB.tbHomeWidgets, map, con);

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

	///----- static --------------------------------------------------------------
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
		await AppDB.db.delete(AppDB.tbHomeWidgets, con);

		_userHolder.removeWhere((element) => element.userId == userId);

		await GreenClientManager.deleteUserFootMark(userId);
	}
}
