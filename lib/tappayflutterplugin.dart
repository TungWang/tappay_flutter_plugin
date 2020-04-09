import 'dart:async';

import 'package:flutter/services.dart';

class Tappayflutterplugin {
  static const MethodChannel _channel =
      const MethodChannel('tappayflutterplugin');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String> setupTappay(int appId, String appKey, String serverType, String cardNumber, String dueMonth, String dueYear, String ccv) async {
    final String result = await _channel.invokeMethod('setupTappay', {
      'appId':appId,
      'appKey':appKey,
      'serverType':serverType,
      'cardNumber':cardNumber,
      'dueMonth':dueMonth,
      'dueYear':dueYear,
      'ccv':ccv
    });
    return result;
  }
}
