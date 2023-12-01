import 'dart:async';

import 'package:app/managers/green_client_manager.dart';
import 'package:app/managers/green_mind_manager.dart';
import 'package:flutter/cupertino.dart';

import 'package:dio/dio.dart';
import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_route/iris_route.dart';
import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/system.dart';
import 'package:iris_tools/models/two_state_return.dart';
import 'package:iris_tools/modules/stateManagers/updater_state.dart';

import 'package:app/managers/api_manager.dart';
import 'package:app/managers/settings_manager.dart';
import 'package:app/services/google_sign_service.dart';
import 'package:app/services/session_service.dart';
import 'package:app/structures/enums/app_events.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/user_model.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_broadcast.dart';
import 'package:app/tools/app/app_http_dio.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_sheet.dart';
import 'package:app/tools/device_info_tools.dart';
import 'package:app/tools/route_tools.dart';

enum EmailVerifyStatus {
  error,
  mustLogin,
  mustRegister,
  waitToVerify;
}

enum EmailLoginStatus {
  error,
  inCorrectUserPass,
  mustRegister,
  waitToVerify,
  ok;
}
///=============================================================================
class LoginService {
  LoginService._();

  static void init(){
    EventNotifierService.addListener(AppEvents.newUserLogin, onLoginObservable);
    EventNotifierService.addListener(AppEvents.userLogoff, onLogoffObservable);
  }

  static void onLoginObservable({dynamic data}){
    GreenMindManager.current?.start();
    GreenClientManager.current?.start();
  }

  static void onLogoffObservable({dynamic data}){
    if(data is UserModel){
      sendLogoffState(data);
    }
  }

  static void sendLogoffState(UserModel user){
    if(AppBroadcast.isNetConnected){
      final reqJs = <String, dynamic>{};
      reqJs[Keys.request] = 'Logoff_user_report';
      reqJs[Keys.requesterId] = user.userId;
      reqJs[Keys.forUserId] = user.userId;

      DeviceInfoTools.attachDeviceAndTokenInfo(reqJs, curUser: user);

      final info = HttpItem();
      info.fullUrl = '${SettingsManager.localSettings.httpAddress}/graph-v1';
      info.method = 'POST';
      info.body = JsonHelper.mapToJson(reqJs);
      info.setResponseIsPlain();

      AppHttpDio.send(info);
    }
  }

  static Future<void> forceLogoff({String? userId}) async {
    var user = SessionService.getExistLoginUserById(userId?? '');
    final lastUser = SessionService.getLastLoginUser();

    if(user == null && lastUser == null) {
      return;
    }

    user ??= lastUser;

    final isCurrent = lastUser != null && lastUser.userId == user!.userId;

    if(user!.email != null){
      /*final google = GoogleSignService();
      await google.signOut();

      if(await google.isSignIn()){
        AppToast.showToast(RouteTools.getTopContext()!, AppMessages.inEmailSignOutError);
        return;
      }*/
    }

    await SessionService.logoff(user.userId);

    UpdaterController.forId(AppBroadcast.drawerMenuRefresherId)?.update();
    AppBroadcast.layoutPageKey.currentState?.scaffoldState.currentState?.closeDrawer();

    if(isCurrent){
      resetApp();
    }
  }

  static Future forceLogoffAll() async {
    while(SessionService.hasAnyLogin()){
      final lastUser = SessionService.getLastLoginUser();

      if(lastUser != null) {
        if (lastUser.email != null) {
          final google = GoogleSignService();
          await google.signOut();
        }
      }
    }

    await SessionService.logoffAll();

    UpdaterController.forId(AppBroadcast.drawerMenuRefresherId)?.update();
    AppBroadcast.layoutPageKey.currentState?.scaffoldState.currentState?.closeDrawer();

    resetApp();
  }

  static void resetApp(){
    if (RouteTools.materialContext != null) {
      RouteTools.backToRoot(RouteTools.getTopContext()!);

      Future.delayed(const Duration(milliseconds: 300), (){
        AppBroadcast.reBuildMaterial();
      });
    }
  }

  static Future<TwoStateReturn<Map, Exception>> requestVerifyAuthEmail({required String email}) async {
    final http = HttpItem();
    final result = Completer<TwoStateReturn<Map, Exception>>();

    final js = {};
    js[Keys.request] = 'verify_email';
    js['email'] = email;
    js.addAll(DeviceInfoTools.mapDeviceInfo());
    DeviceInfoTools.attachDeviceAndTokenInfo(js);

    http.fullUrl = ApiManager.serverApi;
    http.method = 'POST';
    http.setBodyJson(js);

    final request = AppHttpDio.send(http);

    var f = request.response.catchError((e){
      result.complete(TwoStateReturn(r2: e));

      return null;
    });

    f = f.then((Response? response){
      if(response == null || !request.isOk) {
        if(!result.isCompleted){
          result.complete(TwoStateReturn(r2: Exception()));
        }

        return;
      }

      final resJs = request.getBodyAsJson()!;

      result.complete(TwoStateReturn(r1: resJs));
      return null;
    });

    return result.future;
  }

  static Future<bool> loginWithAuthEmail({required String email}) async {
    final http = HttpItem();
    final result = Completer<bool>();

    final js = {};
    js[Keys.request] = 'login_with_auth_email';
    js['email'] = email;
    DeviceInfoTools.attachDeviceAndTokenInfo(js);

    http.fullUrl = ApiManager.serverApi;
    http.method = 'POST';
    http.setBodyJson(js);

    final request = AppHttpDio.send(http);

    var f = request.response.catchError((e){
      result.complete(false);

      return null;
    });

    f = f.then((Response? response) async {
      if(response == null || !request.isOk) {
        if(!result.isCompleted){
          result.complete(false);
        }

        return;
      }

      final status = request.getBodyAsJson()![Keys.status];

      if(status == Keys.error){
        if(!result.isCompleted){
          result.complete(false);
        }
        return;
      }
      final resJs = request.getBodyAsJson()!;
      await SessionService.loginByProfileData(resJs);

      result.complete(true);
      return null;
    });

    return result.future;
  }

  static Future<(EmailVerifyStatus, String?)> requestCheckEmailAndSendVerify({required String email, required String password}) async {
    final Completer<(EmailVerifyStatus, String?)> res = Completer();
    final http = HttpItem();

    final js = {};
    js[Keys.request] = 'send_verify_email';
    js['email'] = email;
    js['hash_password'] = Generator.generateMd5(password);
    js.addAll(DeviceInfoTools.mapDeviceInfo());
    DeviceInfoTools.attachDeviceAndTokenInfo(js);

    http.fullUrl = ApiManager.serverApi;
    http.method = 'POST';
    http.setBodyJson(js);

    final request = AppHttpDio.send(http);

    var f = request.response.catchError((e){
      return null;
    });

    f = f.then((Response? response) async {
      if(response == null || !request.isOk) {
        res.complete((EmailVerifyStatus.error, null));
        return;
      }

      final resJs = request.getBodyAsJson()!;
      final status = resJs[Keys.status];

      if(status == Keys.error){
        res.complete((EmailVerifyStatus.error, null));
      }
      else {
        final mustRegister = resJs['must_register']?? false;
        final mustLogin = resJs['must_login']?? false;
        final mustVerify = resJs['must_verify']?? false;

        if(mustLogin) {
          res.complete((EmailVerifyStatus.mustLogin, email));
        }
        else if(mustRegister) {
          res.complete((EmailVerifyStatus.mustRegister, email));
        }
        else if(mustVerify) {
          res.complete((EmailVerifyStatus.waitToVerify, email));
        }
        else {
          res.complete((EmailVerifyStatus.error, email));
        }
      }

      return null;
    });

    return res.future;
  }

  static Future<(EmailLoginStatus, String?)> requestLoginWithEmail({required String email, required String password}) async {
    final Completer<(EmailLoginStatus, String?)> res = Completer();
    final http = HttpItem();

    final js = {};
    js[Keys.request] = 'login_with_email';
    js['email'] = email;
    js['hash_password'] = Generator.generateMd5(password);
    js.addAll(DeviceInfoTools.mapDeviceInfo());
    DeviceInfoTools.attachDeviceAndTokenInfo(js);

    http.fullUrl = ApiManager.serverApi;
    http.method = 'POST';
    http.setBodyJson(js);

    final request = AppHttpDio.send(http);

    var f = request.response.catchError((e){
      return null;
    });

    f = f.then((Response? response) async {
      if(response == null || !request.isOk) {
        res.complete((EmailLoginStatus.error, null));
        return;
      }

      final resJs = request.getBodyAsJson()!;
      final status = resJs[Keys.status];
      final causeCode = resJs[Keys.causeCode]?? 0;

      if(status == Keys.error){
        if(causeCode == 80 || causeCode == 25) {
          res.complete((EmailLoginStatus.inCorrectUserPass, null));
        }
        else {
          res.complete((EmailLoginStatus.error, null));
        }
      }
      else {
        final userId = resJs[Keys.userId];
        final mustRegister = resJs['must_register']?? false;
        final mustVerify = resJs['must_verify']?? false;

        if (userId != null) {
          final userModel = await SessionService.loginByProfileData(resJs);

          if(userModel != null) {
            resetApp();
            res.complete((EmailLoginStatus.ok, null));
          }
          else {
            res.complete((EmailLoginStatus.error, null));
          }
        }

        if(mustRegister) {
          res.complete((EmailLoginStatus.mustRegister, email));
        }
        else if(mustVerify) {
          res.complete((EmailLoginStatus.waitToVerify, email));
        }
      }

      return null;
    });

    return res.future;
  }

  static Future<void> requestCanRegisterWithEmail({required String code}) async {
    final http = HttpItem();

    final js = {};
    js[Keys.request] = 'is_email_verify';
    js['code'] = code;
    js.addAll(DeviceInfoTools.mapDeviceInfo());
    DeviceInfoTools.attachDeviceAndTokenInfo(js);

    http.fullUrl = ApiManager.serverApi;
    http.method = 'POST';
    http.setBodyJson(js);

    final request = AppHttpDio.send(http);

    var f = request.response.catchError((e){
      return null;
    });

    f = f.then((Response? response) async {
      if(response == null || !request.isOk) {
        return;
      }

      final resJs = request.getBodyAsJson()!;
      final context = RouteTools.materialContext!;
      final status = resJs[Keys.status];
      //final causeCode = resJs[Keys.causeCode]?? 0;
      IrisNavigatorObserver.setAddressBar(IrisNavigatorObserver.appBaseUrl());
      await System.wait(const Duration(milliseconds: 250));

      if(status == Keys.error){
        AppSheet.showSheetOk(context, 'فرایند تایید به درستی انجام نشد، لطفا دوباره وارد شوید').then((value) {
          AppBroadcast.reBuildMaterial();
        });
      }
      else {
        final userId = resJs[Keys.userId];

        if (userId == null) {
          /*final injectData = RegisterPageInjectData();
          injectData.email = resJs['email'];

          RouteTools.pushPage(context, RegisterPage(injectData: injectData));*/
        }
        else {
          final userModel = await SessionService.loginByProfileData(resJs);

          if(userModel != null) {
            resetApp();
          }
          else {
            if(context.mounted){
              AppSheet.showSheetOk(context, AppMessages.operationFailed);
            }
          }
        }
      }

      return null;
    });

    return;
  }

  static loginGuestUser(BuildContext context) async {
    final gUser = SessionService.getGuestUser();
    final userModel = await SessionService.loginByProfileData(gUser.toMap());

    if(userModel != null) {
      resetApp();
    }
    else {
      if(context.mounted) {
        AppSheet.showSheetOk(context, AppMessages.operationFailed);
      }
    }
  }

  static Requester requestRegisterUser(Map<String, dynamic> body, HttpRequestEvents eventHandler){
    final request = Requester();
    request.bodyJson = body;
    request.httpRequestEvents = eventHandler;
    request.prepareUrl();
    request.request();

    return request;
  }
}
