# tappayflutterplugin

This is a Flutter plugin that help developer to use Tappay.

## Getting Started

# How to setup

> Please check the official document of TapPay.
> iOS: https://github.com/TapPay/tappay-ios-example
> android: https://github.com/TapPay/tappay-android-example

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
PrimeModel prime = await Tappayflutterplugin.redirectToEasyWallet(
                    universalLink: universalLink,
                    paymentUrl: paymentUrl,
                  );
```