import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

enum TappayServerType {
  sandBox,
  production,
}

class PrimeModel {
  String status;
  String message;
  String prime;

  PrimeModel({this.status, this.message, this.prime});

  PrimeModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    prime = json['prime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['prime'] = this.prime;
    return data;
  }
}

class TPDEasyWalletResult {
  String status;
  String recTradeId;
  String orderNumber;
  String bankTransactionId;

  TPDEasyWalletResult(
      {this.status, this.recTradeId, this.orderNumber, this.bankTransactionId});

  TPDEasyWalletResult.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    recTradeId = json['recTradeId'];
    orderNumber = json['orderNumber'];
    bankTransactionId = json['bankTransactionId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['recTradeId'] = this.recTradeId;
    data['orderNumber'] = this.orderNumber;
    data['bankTransactionId'] = this.bankTransactionId;
    return data;
  }
}

class Tappayflutterplugin {
  static const MethodChannel _channel =
      const MethodChannel('tappayflutterplugin');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  //設置Tappay環境
  static Future<void> setupTappay({
    int appId,
    String appKey,
    TappayServerType serverType,
    Function(String) errorMessage,
  }) async {
    String st = '';
    switch (serverType) {
      case TappayServerType.sandBox:
        st = 'sandBox';
        break;
      case TappayServerType.production:
        st = 'production';
        break;
    }

    final String error = await _channel.invokeMethod(
      'setupTappay',
      {
        'appId': appId,
        'appKey': appKey,
        'serverType': st,
      },
    );

    if (error != null) {
      errorMessage(error);
    }
  }

  //檢查信用卡的有效性
  static Future<bool> isCardValid({
    String cardNumber,
    String dueMonth,
    String dueYear,
    String ccv,
  }) async {
    final bool isValid = await _channel.invokeMethod(
      'isCardValid',
      {
        'cardNumber': cardNumber,
        'dueMonth': dueMonth,
        'dueYear': dueYear,
        'ccv': ccv,
      },
    );
    return isValid;
  }

  //取得Prime
  static Future<PrimeModel> getPrime({
    String cardNumber,
    String dueMonth,
    String dueYear,
    String ccv,
  }) async {
    String response = await _channel.invokeMethod(
      'getPrime',
      {
        'cardNumber': cardNumber,
        'dueMonth': dueMonth,
        'dueYear': dueYear,
        'ccv': ccv,
      },
    );

    return PrimeModel.fromJson(json.decode(response));
  }

  //檢查是否有安裝Easy wallet
  static Future<bool> isEasyWalletAvailable() async {
    bool response = await _channel.invokeMethod('isEasyWalletAvailable');
    return response;
  }

  //取得Easy wallet prime
  static Future<PrimeModel> getEasyWalletPrime({String universalLink}) async {
    String response = await _channel.invokeMethod(
      'getEasyWalletPrime',
      {'universalLink': universalLink},
    );
    return PrimeModel.fromJson(json.decode(response));
  }

  //重導向至EasyWallet
  static Future<TPDEasyWalletResult> redirectToEasyWallet(
      {String universalLink, String paymentUrl}) async {
    TPDEasyWalletResult result = await _channel.invokeMethod(
      'redirectToEasyWallet',
      {
        'universalLink': universalLink,
        'paymentUrl': paymentUrl,
      },
    );
    return result;
  }
}
