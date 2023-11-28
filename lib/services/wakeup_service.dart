import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:workmanager/workmanager.dart';

import 'package:app/main.dart';
import 'package:app/services/native_call_service.dart';
import 'package:app/system/constants.dart';
import 'package:app/tools/app/app_notification.dart';

@pragma('vm:entry-point')
Future<bool> _callbackWorkManager(task, inputData) async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await prepareDirectoriesAndLogger();

    NativeCallService.init();
    await AppNotification.initial();

    var isAppRun = false;

    try {
      isAppRun = (await NativeCallService.assistanceBridge!.invokeMethod('isAppRun')).$1;
    }
    catch (e) {/**/}

    if (isAppRun) {
      return true;
    }

    /*switch (task) {
      case Workmanager.iOSBackgroundTask:
        break;
    }*/

    return true;
  }
  catch (e) {
    /// if return false, this method call again.(backoffPolicyDelay)
    return false;
  }
}

@pragma('vm:entry-point')
void callbackWorkManager() {
  Workmanager().executeTask(_callbackWorkManager);
}
///=============================================================================
class WakeupService {
  WakeupService._();

  static void init() {
    if(kIsWeb){
      return;
    }

    Workmanager().initialize(
      callbackWorkManager,
      isInDebugMode: false,
    );

    Workmanager().registerPeriodicTask(
      'WorkManager-task-${Constants.appName}',
      'periodic-${Constants.appName}',
      frequency: const Duration(hours: 1),
      initialDelay: const Duration(milliseconds: 15),
      backoffPolicyDelay: const Duration(minutes: 16),
      existingWorkPolicy: ExistingWorkPolicy.keep,
      backoffPolicy: BackoffPolicy.linear,
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );
  }
}
