import 'dart:async';
import 'dart:math';

import 'package:app/managers/green_mind_manager.dart';
import 'package:app/structures/enums/app_events.dart';
import 'package:app/tools/log_tools.dart';
import 'package:flutter/material.dart';
import 'package:iris_notifier/iris_notifier.dart';

import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_websocket/iris_websocket.dart';

import 'package:app/managers/api_manager.dart';
import 'package:app/services/login_service.dart';
import 'package:app/services/session_service.dart';
import 'package:app/structures/models/settings_model.dart';
import 'package:app/system/application_signal.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_broadcast.dart';
import 'package:app/tools/app/app_db.dart';
import 'package:app/tools/app/app_dialog_iris.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_notification.dart';
import 'package:app/tools/device_info_tools.dart';
import 'package:app/tools/http_tools.dart';
import 'package:app/tools/route_tools.dart';

class WebsocketService {
	WebsocketService._();

	static GetSocket? _ws;
	static String? _uri;
	static bool _isInit = false;
	static bool _isConnected = false;
	static bool canReconnectState = true;
	static Duration reconnectInterval = const Duration(seconds: 6);
	static Timer? periodicHeartTimer;
	static Timer? reconnectTimer;
	static String? get address => _uri;
	static bool get isConnected => _isConnected;

	static Future<void> startWebSocket(String uri) async {
		if(!_isInit){
			EventNotifierService.addListener(AppEvents.networkConnected, _netListener);
			_isInit = true;
		}

		_uri = uri;
		_close();
		connect();
	}

	static void _netListener({data}) {
		if(isConnected) {
			return;
		}

		_close();
		connect();
	}

	static void _close() {
		try {
			_isConnected = false;
			_ws?.close(1000);
		}
		catch(e){/**/}
	}

	static void connect() async {
		if(isConnected) {
			return;
		}

		try {
			_ws = GetSocket(_uri!);
			//(_ws as BaseWebSocket).allowSelfSigned = true;
			_ws!.addOpenListener(_onConnected);
			_ws!.addMessageListener(_handlerNewMessage);
			_ws!.addCloseListener((c) => _onDisConnected());
			_ws!.addErrorListener((e) => _onDisConnected());

			_ws!.connect();
		}
		catch(e){
			_onDisConnected();
		}
	}

	static void _reconnect([Duration? delay]){
		if(!canReconnectState) {
			return;
		}

		reconnectTimer?.cancel();

		reconnectTimer = Timer(delay?? reconnectInterval, () {
			if(AppBroadcast.isNetConnected) {
				connect();
			}
		});

		var temp = reconnectInterval.inSeconds;
		temp = min<int>((temp * 1.3).floor(), 600);
		reconnectInterval = Duration(seconds: temp);
	}

	static void shutdown(){
		_close();
		periodicHeartTimer?.cancel();
	}

	static void sendData(dynamic data){
		_ws!.send(data);
	}

	static void _onDisConnected() async {
		_isConnected = false;
		periodicHeartTimer?.cancel();
		ApplicationSignal.onWsDisConnectedListener();

		_reconnect();
	}

	///-------------- on new Connect ---------------------------------------------
	static void _onConnected() async {
		_isConnected = true;
		reconnectInterval = const Duration(seconds: 6);

		sendHeartAndUsers();
		ApplicationSignal.onWsConnectedListener();

		periodicHeartTimer?.cancel();
		periodicHeartTimer = Timer.periodic(
				Duration(minutes: SettingsModel.webSocketPeriodicHeartMinutes), (timer) {
			sendHeartAndUsers();
		});
	}

	///------------ heart every 3 min --------------------------------------------
	static void sendHeartAndUsers() {
		final heart = ApiManager.getHeartMap();

		try {
			sendData(JsonHelper.mapToJson(heart));
		}
		catch(e){
			_isConnected = false;
			periodicHeartTimer?.cancel();
			_reconnect(const Duration(seconds: 6));
		}
	}




	///-------------- onNew Ws Message -------------------------------------------
	static void _handlerNewMessage(dynamic wsData) async {
		Map<String, dynamic> js;

		try {
			if(wsData is! Map<String, dynamic>){
				js = JsonHelper.jsonToMap<String, dynamic>(wsData)!;
			}
			else {
				js = wsData;
			}


			/// section: UserData, Command, none
			final String section = js[Keys.section]?? 'none';
			final String command = js[Keys.command]?? '';
			final userId = js[Keys.userId]?? 0;
			final data = js[Keys.data];

			///---------- process ----------------------------------------
			if(section == HttpCodes.command$section || section == 'none') {
				switch (command) {
					case HttpCodes.com_messageForUser:
						messageForUser(js);
						break;
					case HttpCodes.com_forceLogOff:
						// ignore: unawaited_futures
						LoginService.forceLogoff(userId: userId);
						break;
					case HttpCodes.com_forceLogOffAll:
						// ignore: unawaited_futures
						LoginService.forceLogoffAll();
						break;
					case HttpCodes.com_talkMeWho:
						sendData(JsonHelper.mapToJson(ApiManager.getHeartMap()));
						break;
					case HttpCodes.com_sendDeviceInfo:
						sendData(JsonHelper.mapToJson(DeviceInfoTools.mapDeviceInfo()));
						break;
				}
			}

			if(section == HttpCodes.userData$section){
				userDataSection(userId, command, data, js);
			}
		}
		catch(e){
			LogTools.logger.logToAll('== Websocket error: $e');
		}
	}

	static void userDataSection(int userId, String command, dynamic data, Map js) async {
		if(command == HttpCodes.updateProfileSettings$command) {
			await SessionService.newProfileData(data);
		}

		if(command == HttpCodes.newGreenMain$command) {
			GreenMindManager.newGreenMindFromWs(data);
		}
	}

	static void messageForUser(Map js) async {
		final userId = js[Keys.userId];
		final data = js[Keys.data];
		final message = data['message'];
		final messageId = data['message_id'];

		if(userId != null && userId != SessionService.getLastLoginUser()?.userId){
			return;
		}

		final ids = AppDB.fetchAsList(Keys.setting$userMessageIds);

		if(!ids.contains(messageId)) {
			if(RouteTools.materialContext != null) {
				_promptDialog(RouteTools.getTopContext()!, message);
				AppDB.addToList(Keys.setting$userMessageIds, messageId);
			}
		}
	}

	static _promptDialog(BuildContext context, String msg){
		AppDialogIris.instance.showIrisDialog(
				context,
				yesText: AppMessages.yes,
				desc: msg,
		);
	}

	static _promptNotification(String? title, String msg){
		AppNotification.sendNotification(title, msg);
	}
}
