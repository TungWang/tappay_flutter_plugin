import 'package:flutter/material.dart';
import 'package:tappayflutterplugin/tappayflutterplugin.dart';

import 'constant.dart';

class DirectPayScreen extends StatefulWidget {
  @override
  _DirectPayScreenState createState() => _DirectPayScreenState();
}

class _DirectPayScreenState extends State<DirectPayScreen> {

  //Test card number
  String cardNumber = '4242424242424242';
  String dueMonth = '01';
  String dueYear = '23';
  String ccv = '123';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DirectPay'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'appId: ${appId.toString()}',
            textAlign: TextAlign.center,
          ),
          Text(
            'appKey: $appKey',
            textAlign: TextAlign.center,
          ),
          Text(
            'serverType: ${serverType == TappayServerType.sandBox ? 'sandBox' : 'production'}',
            textAlign: TextAlign.center,
          ),
          Container(
            color: Colors.blue,
            child: FlatButton(
              onPressed: () {
                Tappayflutterplugin.setupTappay(
                    appId: appId,
                    appKey: appKey,
                    serverType: TappayServerType.sandBox,
                    errorMessage: (error) {
                      print(error);
                    });
              },
              child: Text('Setup Tappay'),
            ),
          ),
          Text(
            'cardNumber: $cardNumber',
            textAlign: TextAlign.center,
          ),
          Text(
            'dueMonth: $dueMonth',
            textAlign: TextAlign.center,
          ),
          Text(
            'dueYear: $dueYear',
            textAlign: TextAlign.center,
          ),
          Text(
            'ccv: $ccv',
            textAlign: TextAlign.center,
          ),
          Container(
            color: Colors.blue,
            child: FlatButton(
              onPressed: () async {
                var isCardValid = await Tappayflutterplugin.isCardValid(
                  cardNumber: cardNumber,
                  dueMonth: dueMonth,
                  dueYear: dueYear,
                  ccv: ccv,
                );
                print('isCardValid: $isCardValid');
              },
              child: Text('Is card valid?'),
            ),
          ),
          Container(
            color: Colors.blue,
            child: FlatButton(
              onPressed: () async {
                PrimeModel prime = await Tappayflutterplugin.getPrime(
                  cardNumber: cardNumber,
                  dueMonth: dueMonth,
                  dueYear: dueYear,
                  ccv: ccv,
                );
                if (prime.prime.isEmpty) {
                  print('status: ${prime.status}, message: ${prime.message}');
                } else {
                  print('prime: ${prime.prime}');
                }
              },
              child: Text('Get prime'),
            ),
          ),
        ],
      ),
    );
  }
}
