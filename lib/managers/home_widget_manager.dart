import 'dart:async';

import 'package:app/structures/enums/updater_group.dart';
import 'package:app/structures/models/home_widget_model.dart';
import 'package:iris_db/iris_db.dart';

import 'package:app/services/session_service.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_db.dart';
import 'package:iris_tools/modules/stateManagers/updater_state.dart';

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
	final List<HomeWidgetModel> _itemList = [];
	List<HomeWidgetModel> get items => _itemList;


	Future<void> start() async {
		await fetchAll();
	}

	Future<void> fetchAll() async {
		final con = Conditions();
		con.add(Condition(ConditionType.DefinedNotNull)..key = Keys.id);
		con.add(Condition(ConditionType.EQUAL)..key = Keys.userId..value = userId);

		final res = AppDB.db.query(AppDB.tbHomeWidgets, con);

		for(final x in res){
			_itemList.add(HomeWidgetModel.fromMap(x));
		}
	}

	Future<bool> sink(dynamic widget) async {
		final Map<String, dynamic> map;

		if(widget is HomeWidgetModel){
			map = widget.toMap();
		}
		else {
			map = widget;
		}

		map[Keys.userId] ??= userId;

		final con = Conditions();
		con.add(Condition()..key = 'client_id' .. value = map['client_id']);

		final res = await AppDB.db.insertOrUpdate(AppDB.tbHomeWidgets, map, con);

		return res > -1;
	}

	Future<bool> deleteRecord(int clientId) async {
		final con = Conditions();
		con.add(Condition()..key = 'client_id' .. value = clientId);

		final res = await AppDB.db.delete(AppDB.tbHomeWidgets, con);

		return res > -1;
	}

	HomeWidgetModel? findByClientId(int id){
		return _itemList.firstWhereSafe((element) => element.clientId == id);
	}

	void addHomeWidget(dynamic obj, {bool notify = true}){
		HomeWidgetModel homeWidget;

		if(obj is Map){
			homeWidget = HomeWidgetModel.fromMap(obj);
		}
		else {
			homeWidget = obj;
		}

		final old = findByClientId(homeWidget.clientId);

		if(old != null){
			old.matchBy(homeWidget);
		}
		else {
			_itemList.add(homeWidget);
		}

		sortItemsByOrder();
		sink(homeWidget);

		if(notify) {
			notifyUpdate();
		}
	}

	void sortItemsByOrder(){
		int sorter(HomeWidgetModel m1, HomeWidgetModel m2){
			if(m1.order == m2.order){
				return 0;
			}

			return m1.order > m2.order? 1 : -1;
		}

		_itemList.sort(sorter);
	}

	void addHomeWidgets(List<Map> mapList){
		for(final x in mapList){
			addHomeWidget(x, notify: false);
		}

		notifyUpdate();
	}

	void notifyUpdate(){
		UpdaterController.updateByGroup(UpdaterGroup.homeWidgetUpdate);
	}

	int getLastOrder(){
		int last = -1;

		for(final i in _itemList){
			if(i.order > last){
				last = i.order;
			}
		}

		return last;
	}

  bool existOnHome(int clientId) {
		return _itemList.any((element) => element.clientId == clientId);
	}

  void removeWidget(int clientId, {bool notify = true}) {
		int index = _itemList.indexWhere((element) => element.clientId == clientId);

		if(index < 0){
			return;
		}

		_itemList.removeWhere((element) => element.clientId == clientId);
		reorderFrom(index);

		deleteRecord(clientId);

		if(notify){
			notifyUpdate();
		}
	}

	void reorderFrom(int index){
		_itemList.skip(index).forEach((element) {
			element.order--;
		});
	}
}
