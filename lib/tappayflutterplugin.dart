import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

enum TappayServerType {
  sandBox,
  production,
}

enum TPDCardType { unknown, visa, masterCard, jcb, americanExpress, unionPay }

enum TPDCardAuthMethod { panOnly, cryptogram3ds }

class PrimeModel {
  String? status;
  String? message;
  String? prime;

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
  String? status;
  String? recTradeId;
  String? orderNumber;
  String? bankTransactionId;

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

class TPDLinePayResult {
  String? status;
  String? recTradeId;
  String? orderNumber;
  String? bankTransactionId;

  TPDLinePayResult(
      {this.status, this.recTradeId, this.orderNumber, this.bankTransactionId});

  TPDLinePayResult.fromJson(Map<String, dynamic> json) {
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
    required int appId,
    required String appKey,
    required TappayServerType serverType,
    required Function(String) errorMessage,
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

    final String? error = await _channel.invokeMethod(
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
    required String cardNumber,
    required String dueMonth,
    required String dueYear,
    required String ccv,
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
    required String cardNumber,
    required String dueMonth,
    required String dueYear,
    required String ccv,
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
    bool response = await _channel.invokeMethod('isEasyWalletAvailable', {});
    return response;
  }

  //取得Easy wallet prime
  static Future<PrimeModel> getEasyWalletPrime(
      {required String universalLink}) async {
    String response = await _channel.invokeMethod(
      'getEasyWalletPrime',
      {'universalLink': universalLink},
    );
    return PrimeModel.fromJson(json.decode(response));
  }

  //重導向至EasyWallet
  static Future<TPDEasyWalletResult> redirectToEasyWallet(
      {required String universalLink, required String paymentUrl}) async {
    String result = await _channel.invokeMethod(
      'redirectToEasyWallet',
      {
        'universalLink': universalLink,
        'paymentUrl': paymentUrl,
      },
    );
    return TPDEasyWalletResult.fromJson(json.decode(result));
  }

  //解析Easy wallet result
  static Future<void> parseToEasyWalletResult(
      {required String universalLink, required String uri}) async {
    await _channel.invokeMethod(
      'parseToEasyWalletResult',
      {
        'universalLink': universalLink,
        'uri': uri,
      },
    );
    return;
  }

  //取得Easy wallet result
  static Future<TPDEasyWalletResult?> getEasyWalletResult() async {
    String result = await _channel.invokeMethod(
      'getEasyWalletResult',
    );

    try {
      return TPDEasyWalletResult.fromJson(json.decode(result));
    } catch (e) {
      print(e);
      print(result);
      return null;
    }
  }

  //檢查是否有安裝LinePay
  static Future<bool> isLinePayAvailable() async {
    var response = await _channel.invokeMethod('isLinePayAvailable', {});
    return response;
  }

  //取得Line pay prime
  static Future<PrimeModel> getLinePayPrime(
      {required String universalLink}) async {
    String response = await _channel.invokeMethod(
      'getLinePayPrime',
      {'universalLink': universalLink},
    );
    return PrimeModel.fromJson(json.decode(response));
  }

  //重導向至LinePay
  static Future<TPDLinePayResult> redirectToLinePay(
      {required String universalLink, required String paymentUrl}) async {
    String result = await _channel.invokeMethod(
      'redirectToLinePay',
      {
        'universalLink': universalLink,
        'paymentUrl': paymentUrl,
      },
    );
    return TPDLinePayResult.fromJson(json.decode(result));
  }

  //解析line pay result
  static Future<void> parseToLinePayResult(
      {required String universalLink, required String uri}) async {
    await _channel.invokeMethod(
      'parseToLinePayResult',
      {
        'universalLink': universalLink,
        'uri': uri,
      },
    );
    return;
  }

  //取得line pay result
  static Future<TPDLinePayResult?> getLinePayResult() async {
    String result = await _channel.invokeMethod(
      'getLinePayResult',
    );

    try {
      return TPDLinePayResult.fromJson(json.decode(result));
    } catch (e) {
      print(e);
      print(result);
      return null;
    }
  }

  //GooglePay prepare payment data
  static Future<void> preparePaymentData({
    required List<TPDCardType> allowedNetworks,
    required List<TPDCardAuthMethod> allowedAuthMethods,
    required String merchantName,
    required bool isPhoneNumberRequired,
    required bool isShippingAddressRequired,
    required bool isEmailRequired,
  }) async {
    List<int> networks = [];
    for (var i in allowedNetworks) {
      int value;
      switch (i) {
        case TPDCardType.unknown:
          value = 0;
          break;
        case TPDCardType.visa:
          value = 2;
          break;
        case TPDCardType.masterCard:
          value = 3;
          break;
        case TPDCardType.jcb:
          value = 1;
          break;
        case TPDCardType.americanExpress:
          value = 4;
          break;
        case TPDCardType.unionPay:
          value = 5;
          break;
      }
      networks.add(value);
    }

    List<int> methods = [];
    for (var i in allowedAuthMethods) {
      int value;
      switch (i) {
        case TPDCardAuthMethod.panOnly:
          value = 0;
          break;
        case TPDCardAuthMethod.cryptogram3ds:
          value = 1;
          break;
      }
      methods.add(value);
    }

    await _channel.invokeMethod(
      'preparePaymentData',
      {
        'allowedNetworks': networks,
        'allowedAuthMethods': methods,
        'merchantName': merchantName,
        'isPhoneNumberRequired': isPhoneNumberRequired,
        'isShippingAddressRequired': isShippingAddressRequired,
        'isEmailRequired': isEmailRequired,
      },
    );
    return;
  }

  //request google pay payment data
  static Future<void> requestPaymentData(
      String totalPrice, String currencyCode) async {
    await _channel.invokeMethod(
      'requestPaymentData',
      {
        'totalPrice': totalPrice,
        'currencyCode': currencyCode,
      },
    );
  }

  //Get google pay prime
  static Future<void> getGooglePayPrime() async {
    await _channel.invokeMethod('getGooglePayPrime');
  }
}
