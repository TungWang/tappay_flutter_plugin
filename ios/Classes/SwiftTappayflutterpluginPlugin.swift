import Flutter
import UIKit
import TPDirect
import AdSupport

public class SwiftTappayflutterpluginPlugin: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "tappayflutterplugin", binaryMessenger: registrar.messenger())
        let instance = SwiftTappayflutterpluginPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)
    }
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
        TPDLinePay.addExceptionObserver(#selector(tappayLinePayExceptionHandler(notofication:)))
        TPDEasyWallet.addExceptionObserver(#selector(tappayEasyWalletExceptionHandler(notofication:)))
        return true
    }
    
    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let tapPayHandled = TPDLinePay.handle(url)
        if (tapPayHandled) {
            return true
        }
        
        return false
    }
    
    public func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]) -> Void) -> Bool {
        if let url = userActivity.webpageURL {
            let easyWalletHandled = TPDEasyWallet.handleUniversalLink(url)
            if (easyWalletHandled) {
                return true
            }
        }
        return true
    }
    
    @objc func tappayLinePayExceptionHandler(notofication: Notification) {
        
        let result : TPDLinePayResult = TPDLinePay.parseURL(notofication)
        
        print("status : \(result.status) , orderNumber : \(result.orderNumber ?? "") , recTradeid : \(result.recTradeId ?? "") , bankTransactionId : \(result.bankTransactionId ?? "") ")
        
    }
    
    @objc func tappayEasyWalletExceptionHandler(notofication: Notification) {
        
        let result : TPDEasyWalletResult = TPDEasyWallet.parseURL(notofication)
        
        print("status : \(result.status) , orderNumber : \(result.orderNumber ?? "") , recTradeid : \(result.recTradeId ?? "") , bankTransactionId : \(result.bankTransactionId ?? "") ")
        
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
            
        case "isEasyWalletAvailable":
            result(isEasyWalletAvailable())
            
        case "getEasyWalletPrime":
            getEasyWalletPrime(args: args) { (prime) in
                result(prime)
            } failCallBack: { (message) in
                result(message)
            }
            
        case "redirectToEasyWallet":
            redirectToEasyWallet(args: args) { (callBack) in
                result(callBack)
            }
            
        case "isLinePayAvailable":
            result(isLinePayAvailable())
            
        case "getLinePayPrime":
            getLinePayPrime(args: args) { (prime) in
                result(prime)
            } failCallBack: { (message) in
                result(message)
            }
            
        case "redirectToLinePay":
            redirectToLinePay(args: args) { (callBack) in
                result(callBack)
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
//        TPDSetup.shareInstance().setupIDFA(ASIdentifierManager.shared().advertisingIdentifier.uuidString)
//        TPDSetup.shareInstance().serverSync()
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
        card.onSuccessCallback { (tpPrime, cardInfo, cardIdentifier, merchantReferenceInfo) in
            if let tpPrime = tpPrime {
                prime("{\"status\":\"\", \"message\":\"\", \"prime\":\"\(tpPrime)\"}")
            }
        }.onFailureCallback { (status, message) in
            failCallBack("{\"status\":\"\(status)\", \"message\":\"\(message)\", \"prime\":\"\"}")
        }.createToken(withGeoLocation: "UNKNOWN")
    }
    
    //檢查是否有安裝Easy wallet
    fileprivate func isEasyWalletAvailable() -> Bool {
        return TPDEasyWallet.isEasyWalletAvailable()
    }
    
    
    //取得Easy wallet prime
    fileprivate func getEasyWalletPrime(args: [String:Any], prime: @escaping(String) -> Void, failCallBack: @escaping(String) -> Void) {
        
        let universalLink = (args["universalLink"] as? String ?? "")
        
        if (universalLink.isEmpty) {
            failCallBack("{\"status\":\"\", \"message\":\"universalLink is empty\", \"prime\":\"\"}")
            return
        }
        
        let easyWallet = TPDEasyWallet.setup(withReturUrl: universalLink)
        easyWallet.onSuccessCallback { (tpPrime) in
            
            if let tpPrime = tpPrime {
                prime("{\"status\":\"\", \"message\":\"\", \"prime\":\"\(tpPrime)\"}")
            }
            
        }.onFailureCallback { (status, message) in
            
            failCallBack("{\"status\":\"\(status)\", \"message\":\"\(message)\", \"prime\":\"\"}")
            
        }.getPrime()
        
    }
    
    //重導向至Easy wallet
    fileprivate func redirectToEasyWallet(args: [String:Any], callBack: @escaping(String) -> Void) {
        
        let universalLink = (args["universalLink"] as? String ?? "")
        let easyWallet = TPDEasyWallet.setup(withReturUrl: universalLink)
        
        let paymentUrl = (args["paymentUrl"] as? String ?? "")
        easyWallet.redirect(paymentUrl) { (result) in
            callBack("{\"status\":\"\(String(result.status))\", \"recTradeId\":\"\(String(result.recTradeId))\", \"orderNumber\":\"\(String(result.orderNumber))\", \"bankTransactionId\":\"\(String(result.bankTransactionId))\"}")
        }
    }
    
    //檢查是否有安裝Line pay
    fileprivate func isLinePayAvailable() -> Bool {
        let result = TPDLinePay.isLinePayAvailable()
        return result
    }
    
    
    //取得line pay prime
    fileprivate func getLinePayPrime(args: [String:Any], prime: @escaping(String) -> Void, failCallBack: @escaping(String) -> Void) {
        
        let universalLink = (args["universalLink"] as? String ?? "")
        
        if (universalLink.isEmpty) {
            failCallBack("{\"status\":\"\", \"message\":\"universalLink is empty\", \"prime\":\"\"}")
            return
        }
        
        let linePay = TPDLinePay.setup(withReturnUrl: universalLink)
        linePay.onSuccessCallback { (tpPrime) in
            
            if let tpPrime = tpPrime {
                prime("{\"status\":\"\", \"message\":\"\", \"prime\":\"\(tpPrime)\"}")
            }
            
        }.onFailureCallback { (status, message) in
            
            failCallBack("{\"status\":\"\(status)\", \"message\":\"\(message)\", \"prime\":\"\"}")
            
        }.getPrime()
        
    }
    
    //重導向至line pay
    fileprivate func redirectToLinePay(args: [String:Any], callBack: @escaping(String) -> Void) {
        
        let universalLink = (args["universalLink"] as? String ?? "")
        let linePay = TPDLinePay.setup(withReturnUrl: universalLink)
        
        let paymentUrl = (args["paymentUrl"] as? String ?? "")
        
//        let rootViewController = UIApplication.shared.windows.filter({ (w) -> Bool in
//                    return w.isHidden == false
//         }).first?.rootViewController
        
        guard let vc = UIApplication.shared.delegate?.window??.rootViewController else { return }
        
        linePay.redirect(paymentUrl, with: vc) { (result) in
            callBack("{\"status\":\"\(String(result.status))\", \"recTradeId\":\"\(String(result.recTradeId))\", \"orderNumber\":\"\(String(result.orderNumber))\", \"bankTransactionId\":\"\(String(result.bankTransactionId))\"}")
        }
    }
}
