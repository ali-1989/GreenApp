import 'dart:async';

import 'package:app/structures/models/home_chart_model.dart';


class HomeChartManager {
	HomeChartManager._();

	static final List<HomeChartModel> _itemList = [];
	static bool _isInit = false;

	static Future init() async {
		if(_isInit){
			return true;
		}

		await fetch();
		_isInit = true;
	}

	static List<HomeChartModel> get list => _itemList;

	static Future<void> sink() async {

	}

	static Future<void> fetch() async {
		await Future.delayed(Duration(seconds: 3), (){
			print('---> fetch chart ');
		});
	}
}
