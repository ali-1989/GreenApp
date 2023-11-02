import 'dart:async';

import 'package:app/structures/enums/updater_group.dart';
import 'package:app/structures/models/green_mind_model.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_db.dart';
import 'package:iris_db/iris_db.dart';
import 'package:iris_tools/modules/stateManagers/updater_state.dart';

class GreenMindManager {
	GreenMindManager._();

	static final List<GreenMindModel> _itemList = [];
	static bool _isInit = false;

	static List<GreenMindModel> get items => _itemList;
	static Future init() async {
		if(_isInit){
			return true;
		}

		fetchAll();
		_isInit = true;
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

	static bool exist(GreenMindModel greenMind){
		return _itemList.indexWhere((element) => element.id == greenMind.id) != -1;
	}

	static void addGreenMind(dynamic greenMind, {bool notify = true}){
		if(greenMind is Map){
			greenMind = GreenMindModel.fromMap(greenMind);
		}

		if(exist(greenMind)){
			return;
		}

		_itemList.add(greenMind);
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
		UpdaterController.updateByGroup(UpdaterGroup.grinMindListUpdate);
	}
}
