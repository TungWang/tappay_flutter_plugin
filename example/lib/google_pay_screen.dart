import 'package:flutter/material.dart';
import 'package:tappayflutterplugin/tappayflutterplugin.dart';
import 'constant.dart';

class GooglePayScreen extends StatefulWidget {
  @override
  _GooglePayScreenState createState() => _GooglePayScreenState();
}

class _GooglePayScreenState extends State<GooglePayScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GooglePay'),
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
          Container(
            color: Colors.blue,
            child: FlatButton(
              onPressed: () {
                Tappayflutterplugin.preparePaymentData(
                  allowedNetworks: [
                    TPDCardType.masterCard,
                  ],
                  allowedAuthMethods: [
                    TPDCardAuthMethod.panOnly,
                  ],
                  merchantName: 'TEST MERCHANT',
                  isShippingAddressRequired: false,
                  isEmailRequired: false,
                  isPhoneNumberRequired: false,
                );
              },
              child: Text('Prepare google pay'),
            ),
          ),
          Container(
            color: Colors.blue,
            child: FlatButton(
              onPressed: () async {
                await Tappayflutterplugin.requestPaymentData('100', 'TWD');
              },
              child: Text('Request payment data'),
            ),
          ),
          Container(
            color: Colors.blue,
            child: FlatButton(
              onPressed: () async {
                await Tappayflutterplugin.getGooglePayPrime();
              },
              child: Text('Get google pay prime'),
            ),
          ),
        ],
      ),
    );
  }
}
