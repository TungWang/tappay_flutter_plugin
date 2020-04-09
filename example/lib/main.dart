import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:tappayflutterplugin/tappayflutterplugin.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    getPrime();
  }

  Future<void> getPrime() async {
    final int appId = 0;
    final String appKey = '';
    final String serverType = 'sandBox';
    final String cardNumber = '4242424242424242';
    final String dueMonth = '01';
    final String dueYear = '23';
    final String ccv = '123';
    final prime = await Tappayflutterplugin.setupTappay(appId, appKey, serverType, cardNumber, dueMonth, dueYear, ccv);
    print('prime is $prime');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
