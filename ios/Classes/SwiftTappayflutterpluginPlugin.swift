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
        
        guard let args = call.arguments as? [String:Any] else {
            result("args cast error")
            return
        }
        
        switch method {
        case "setupTappay":
            setupTappay(args: args) { (error) in
                result(error)
            }
            
        case "isCardValid":
            result(isCardValid(args: args))
            
        case "getPrime":
            getPrime(args: args) { (prime) in
                result(prime)
            } failCallBack: { (message) in
                result(message)
            }
            
        default:
            result("iOS " + UIDevice.current.systemVersion)
        }
        
    }
    
    //設置Tappay環境
    fileprivate func setupTappay(args: [String:Any], errorMessage: @escaping(String) -> Void) {
        
        var message: String = ""
        
        let appId = (args["appId"] as? Int32 ?? 0)
        let appKey = (args["appKey"] as? String ?? "")
        let serverType = (args["serverType"] as? String ?? "")
        
        if appId == 0 {
            message += "appId error"
        }
        
        if appKey.isEmpty {
            message += "/appKey error"
        }
        
        if serverType.isEmpty {
            message += "/serverType error"
        }
        
        if !message.isEmpty {
            errorMessage(message)
            return
        }
        
        let st: TPDServerType = {
            return serverType == "sandBox" ? TPDServerType.sandBox : TPDServerType.production
        }()
        
        
        TPDSetup.setWithAppId(appId, withAppKey: appKey, with: st)
        TPDSetup.shareInstance().setupIDFA(ASIdentifierManager.shared().advertisingIdentifier.uuidString)
        TPDSetup.shareInstance().serverSync()
    }
    
    //檢查信用卡的有效性
    fileprivate func isCardValid(args: [String:Any]) -> Bool {
        
        let cardNumber = (args["cardNumber"] as? String ?? "")
        let dueMonth = (args["dueMonth"] as? String ?? "")
        let dueYear = (args["dueYear"] as? String ?? "")
        let ccv = (args["ccv"] as? String ?? "")
        
        
        guard let cardValidResult = TPDCard.validate(withCardNumber: cardNumber, withDueMonth: dueMonth, withDueYear: dueYear, withCCV: ccv) else { return false }
        
        if cardValidResult.isCardNumberValid && cardValidResult.isExpiryDateValid && cardValidResult.isCCVValid {
            return true
        }else{
            return false
        }
    }
    
    //取得prime
    fileprivate func getPrime(args: [String:Any], prime: @escaping(String) -> Void, failCallBack: @escaping(String) -> Void) {
        
        let cardNumber = (args["cardNumber"] as? String ?? "")
        let dueMonth = (args["dueMonth"] as? String ?? "")
        let dueYear = (args["dueYear"] as? String ?? "")
        let ccv = (args["ccv"] as? String ?? "")
        
        let card = TPDCard.setWithCardNumber(cardNumber, withDueMonth: dueMonth, withDueYear: dueYear, withCCV: ccv)
        card.onSuccessCallback { (tpPrime, cardInfo, cardIdentifier) in
            if let tpPrime = tpPrime {
                prime("{\"status\":\"\", \"message\":\"\", \"prime\":\"\(tpPrime)\"}")
            }
        }.onFailureCallback { (status, message) in
            failCallBack("{\"status\":\"\(status)\", \"message\":\"\(message)\", \"prime\":\"\"}")
        }.createToken(withGeoLocation: "UNKNOWN")
    }
}
