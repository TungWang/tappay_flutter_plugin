# tappayflutterplugin

This is a Flutter plugin that help developer to use Tappay.

## Getting Started

# How to setup

Please check the official document of TapPay. 
- iOS: https://github.com/TapPay/tappay-ios-example
- android: https://github.com/TapPay/tappay-android-example

# Usage

## Direct Pay

### 1. Set up your environment
``` dart
Tappayflutterplugin.setupTappay(
                         appId: appId,
                         appKey: appKey,
                         serverType: TappayServerType.sandBox,
                         errorMessage: (error) {
                           print(error);
                         });
```

### 2. Get prime
``` dart
PrimeModel prime = await Tappayflutterplugin.getPrime(
                    cardNumber: cardNumber,
                    dueMonth: dueMonth,
                    dueYear: dueYear,
                    ccv: ccv,
                  );
```

## Easy wallet

### IsEasyWalletAvailable
``` dart
bool isEasyWalletAvailable = await Tappayflutterplugin.isEasyWalletAvailable()
```

### Get prime
``` dart
PrimeModel prime = await Tappayflutterplugin.getEasyWalletPrime(
                    universalLink: universalLink,
                  );
```

### Redirect to Easy wallet
``` dart
TPDEasyWalletResult result = await Tappayflutterplugin.redirectToEasyWallet(
                    universalLink: universalLink,
                    paymentUrl: paymentUrl,
                  );
```

### Parse to Easy wallet result
- After finished the payment process, tappay will give you an uri from onNewIntent in android. Use this uri to query LinePay result.
``` dart
TPDEasyWalletResult result = await Tappayflutterplugin.parseToEasyWalletResult(
                    universalLink: universalLink,
                    uri: uri,
                  );
```

### Get Easy wallet result
``` dart
TPDEasyWalletResult result = await Tappayflutterplugin.getEasyWalletResult();
```

## LinePay

### IsLinePayAvailable
``` dart
bool isLinePayAvailable = await Tappayflutterplugin.isLinePayAvailable()
```

### Get prime
``` dart
PrimeModel prime = await Tappayflutterplugin.getLinePayPrime(
                    universalLink: universalLink,
                  );
```

### Redirect to LinePay
- In android, you have to go to next step, to get result.
``` dart
TPDLinePayResult result = await Tappayflutterplugin.redirectToLinePay(
                    universalLink: universalLink,
                    paymentUrl: paymentUrl,
                  );
```

### Parse to LinePay result
- After finished the payment process, tappay will give you an uri from onNewIntent in android. Use this uri to query LinePay result.
``` dart
TPDLinePayResult result = await Tappayflutterplugin.parseToLinePayResult(
                    universalLink: universalLink,
                    uri: uri,
                  );
```

### Get LinePay result
``` dart
TPDLinePayResult result = await Tappayflutterplugin.getLinePayResult();
```