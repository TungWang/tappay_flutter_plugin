import Flutter
import UIKit
import TPDirect
import AdSupport

public class SwiftTappayflutterpluginPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
            let channel = FlutterMethodChannel(name: "tappayflutterplugin", binaryMessenger: registrar.messenger())
            let instance = SwiftTappayflutterpluginPlugin()
            registrar.addMethodCallDelegate(instance, channel: channel)
        }

        public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

            let method = call.method

            switch method {
            case "setupTappay":

                if let args = call.arguments as? [String:Any] {

                    let appId = (args["appId"] as? Int32 ?? 0)
                    let appKey = (args["appKey"] as? String ?? "")
                    let serverType = (args["serverType"] as? String ?? "")
                    let cardNumber = (args["cardNumber"] as? String ?? "")
                    let dueMonth = (args["dueMonth"] as? String ?? "")
                    let dueYear = (args["dueYear"] as? String ?? "")
                    let ccv = (args["ccv"] as? String ?? "")

                    let st: TPDServerType = {
                        return serverType == "sandBox" ? TPDServerType.sandBox : TPDServerType.production
                    }()

                    setupTappay(appId: appId, appKey: appKey, serverType: st, cardNumber: cardNumber, dueMonth: dueMonth, dueYear: dueYear, ccv: ccv, prime: { (prime) in
                        result(prime)
                    }) { (failCallBack) in
                        result(failCallBack)
                    }

                }else{
                    result("setupTappay中的args轉型失敗")
                }


            default:
                result("iOS " + UIDevice.current.systemVersion)
            }

        }

        fileprivate func setupTappay(appId: Int32, appKey: String, serverType: TPDServerType, cardNumber: String, dueMonth: String, dueYear: String, ccv: String, prime: @escaping(String) -> Void, failCallBack: @escaping(String) -> Void) {

            TPDSetup.setWithAppId(appId, withAppKey: appKey, with: serverType)
            TPDSetup.shareInstance().setupIDFA(ASIdentifierManager.shared().advertisingIdentifier.uuidString)
            TPDSetup.shareInstance().serverSync()

            let card = TPDCard.setWithCardNumber(cardNumber, withDueMonth: dueMonth, withDueYear: dueYear, withCCV: ccv)
            card.onSuccessCallback { (tpPrime, cardInfo, cardIdentifier) in
                if let tpPrime = tpPrime {
                    prime(tpPrime)
                }
            }.onFailureCallback { (status, message) in
                failCallBack("Status: \(status), Message: \(message)")
            }.createToken(withGeoLocation: "UNKNOWN")


        }
}
