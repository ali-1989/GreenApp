import 'package:network_info_plus/network_info_plus.dart';

/// src: https://pub.dev/packages/network_info_plus (android/ios/win/linux/mac)

class WifiInfoTools {
  static final info = NetworkInfo();

  WifiInfoTools._();

  static Future<String?> get ssid => info.getWifiName();
  static Future<String?> get bssid => info.getWifiBSSID();
  static Future<String?> get broadcast => info.getWifiBroadcast();
  static Future<String?> get ip => info.getWifiIP();
  static Future<String?> get gatewayIp => info.getWifiGatewayIP();
}