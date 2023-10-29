import 'dart:async';

import 'package:app/structures/enums/user_guide_key.dart';
import 'package:app/structures/models/user_guide_model.dart';
import 'package:app/system/extensions.dart';

class UserGuideManager {
	UserGuideManager._();

	static final List<UserGuideModel> _itemList = [];
	static bool _isInit = false;

	static Future init() async {
		if(_isInit){
			return true;
		}

		await fetch();
		_isInit = true;
	}

	static Future<void> sink() async {

	}

	static Future<void> fetch() async {
		await Future.delayed(Duration(seconds: 3), (){
			print('---> user guide ');
		});
	}

	static bool userIsGuided(UserGuideKey key){
		final itm = _itemList.firstWhereSafe((element) => element.key == key);
		return itm != null && itm.isGuided();
	}
}
