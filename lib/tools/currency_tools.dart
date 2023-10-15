import 'package:intl/intl.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';

import 'package:app/managers/settings_manager.dart';

//import 'package:currency_formatter/currency_formatter.dart';

class CurrencyTools {
  CurrencyTools._();

  static String formatCurrency(num cur, {String name = '', String? symbol}){
    final format = NumberFormat.currency(
      locale: SettingsManager.localSettings.appLocale.languageCode,
      name: name,
      symbol: symbol,
      decimalDigits: 0,
      //customPattern: ,
    );

    return format.format(cur);
  }

  static String formatCurrencyString(String? cur, {String name = '', String? symbol}){
    if(cur == null || cur.isEmpty){
      return '';
    }

    return formatCurrency(MathHelper.clearToDouble(cur), name: name, symbol: symbol);
  }
}
