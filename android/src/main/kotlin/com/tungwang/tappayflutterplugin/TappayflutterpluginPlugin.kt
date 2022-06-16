package com.tungwang.tappayflutterplugin

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.util.Log
import androidx.annotation.NonNull
import com.google.android.gms.common.api.Status
import com.google.android.gms.wallet.AutoResolveHelper
import com.google.android.gms.wallet.PaymentData
import com.google.android.gms.wallet.TransactionInfo
import com.google.android.gms.wallet.WalletConstants
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import tech.cherri.tpdirect.api.*

private var paymentData: PaymentData? = null

/** TappayflutterpluginPlugin */
class TappayflutterpluginPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {
  lateinit var plugin: TappayflutterpluginPlugin
  private var LOAD_PAYMENT_DATA_REQUEST_CODE = 102
  private var context: Context? = null
  private var activity: Activity? = null
  private var tpdLinePayResultListenerInterface: TPDLinePayResultListenerInterface = TPDLinePayResultListenerInterface()
  private val tpdEasyWalletResultListenerInterface: TPDEasyWalletResultListenerInterface = TPDEasyWalletResultListenerInterface()
  private val tpdGooglePayListenerInterfaceInterface: TPDGooglePayListenerInterface = TPDGooglePayListenerInterface()
  private val tpdMerchant = TPDMerchant()
  private val tpdConsumer = TPDConsumer()
  private var tpdGooglePay: TPDGooglePay? = null

  constructor()

  constructor(context: Context) {
    this.context = context
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    val channel = MethodChannel(flutterPluginBinding.binaryMessenger, "tappayflutterplugin")
    plugin = TappayflutterpluginPlugin(flutterPluginBinding.applicationContext)
    channel.setMethodCallHandler(plugin)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    binding.addActivityResultListener(this)
    plugin.activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
//    TODO("Not yet implemented")
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
//    TODO("Not yet implemented")
  }

  override fun onDetachedFromActivity() {
//    TODO("Not yet implemented")
  }

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
    when (requestCode) {
      LOAD_PAYMENT_DATA_REQUEST_CODE -> when (resultCode) {
        Activity.RESULT_OK -> {
          if (data != null) {
            paymentData = PaymentData.getFromIntent(data)
          }
        }
        Activity.RESULT_CANCELED -> {
          Log.d("RESULT_CANCELED", data.toString())
        }
        AutoResolveHelper.RESULT_ERROR -> {
          val status: Status? = AutoResolveHelper.getStatusFromIntent(data)
          if (status != null) {
            Log.d("RESULT_ERROR", "AutoResolveHelper.RESULT_ERROR : " + status.statusCode.toString() + " , message = " + status.statusMessage)
          }
        }
      }
    }
    return false
  }

//  companion object : PluginRegistry.ActivityResultListener {
//    @JvmStatic
//    fun registerWith(registrar: Registrar) {
//      val channel = MethodChannel(registrar.messenger(), "tappayflutterplugin")
//      val plugin = TappayflutterpluginPlugin(registrar.context())
//      channel.setMethodCallHandler(plugin)
//
//      registrar.addActivityResultListener(this)
//
//    }
//
//    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
//      TODO("Not yet implemented")
//    }
//  }

//  fun registerWith(registrar: PluginRegistry.Registrar) {
//    val channel = MethodChannel(registrar.messenger(), "tappayflutterplugin")
//    val plugin = TappayflutterpluginPlugin(registrar.context())
//    channel.setMethodCallHandler(plugin)
//    registrar.addActivityResultListener(this)
//  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {

    when (call.method) {
      in "setupTappay" -> {
        if (context == null) {
          result.error("", "context is null", "")
        } else {
          val appId: Int? = call.argument("appId")
          val appKey: String? = call.argument("appKey")
          val serverType: String? = call.argument("serverType")
          setupTappay(appId, appKey, serverType, errorMessage = { result.error("", it, "") })
        }
      }

      in "isCardValid" -> {
        if (context == null) {
          result.error("", "context is null", "")
        } else {
          val cardNumber: String? = call.argument("cardNumber")
          val dueMonth: String? = call.argument("dueMonth")
          val dueYear: String? = call.argument("dueYear")
          val ccv: String? = call.argument("ccv")
          result.success(isCardValid(cardNumber, dueMonth, dueYear, ccv))
        }
      }

      in "getPrime" -> {
        if (context == null) {
          result.error("", "context is null", "")
        } else {
          val cardNumber: String? = call.argument("cardNumber")
          val dueMonth: String? = call.argument("dueMonth")
          val dueYear: String? = call.argument("dueYear")
          val ccv: String? = call.argument("ccv")
          getPrime(cardNumber, dueMonth, dueYear, ccv, prime = {
            result.success(it)
          }, failCallBack = {
            result.success(it)
          })
        }
      }

      in "isEasyWalletAvailable" -> {
        if (context == null) {
          result.error("", "context is null", "")
        } else {
          result.success(isEasyWalletAvailable())
        }
      }

      in "getEasyWalletPrime" -> {
        if (context == null) {
          result.error("", "context is null", "")
        } else {
          val universalLink: String? = call.argument("universalLink")
          getEasyWalletPrime(universalLink, prime = {
            result.success(it)
          }, failCallBack = {
            result.success(it)
          })
        }
      }

      in "redirectToEasyWallet" -> {
        if (context == null) {
          result.error("", "context is null", "")
        } else {
          val universalLink: String? = call.argument("universalLink")
          val paymentUrl: String? = call.argument("paymentUrl")
          redirectToEasyWallet(universalLink, paymentUrl, callBack = {
            result.success(it)
          })
        }
      }

      in "parseToEasyWalletResult" -> {
        if (context == null) {
          result.error("", "context is null", "")
        } else {
          val universalLink: String? = call.argument("universalLink")
          val uri: String? = call.argument("uri")
          parseToEasyWalletResult(universalLink, uri, failCallBack = {
            result.success(it)
          }, successCallBack = {
            result.success(it)
          })
        }
      }

      in "getEasyWalletResult" -> {
        if (context == null) {
          result.error("", "context is null", "")
        } else {
          getEasyWalletResult {
            result.success(it)
          }
        }
      }

      in "isLinePayAvailable" -> {
        if (context == null) {
          result.error("", "context is null", "")
        } else {
          result.success(isLinePayAvailable())
        }
      }

      in "getLinePayPrime" -> {
        if (context == null) {
          result.error("", "context is null", "")
        } else {
          val universalLink: String? = call.argument("universalLink")
          getLinePayPrime(universalLink, prime = {
            result.success(it)
          }, failCallBack = {
            result.success(it)
          })
        }
      }

      in "redirectToLinePay" -> {
        if (context == null) {
          result.error("", "context is null", "")
        } else {
          val universalLink: String? = call.argument("universalLink")
          val paymentUrl: String? = call.argument("paymentUrl")
          redirectToLinePay(universalLink, paymentUrl, callBack = {
            result.success(it)
          })
        }
      }

      in "parseToLinePayResult" -> {
        if (context == null) {
          result.error("", "context is null", "")
        } else {
          val universalLink: String? = call.argument("universalLink")
          val uri: String? = call.argument("uri")
          parseToLinePayResult(universalLink, uri, failCallBack = {
            result.success(it)
          }, successCallBack = {
            result.success(it)
          })
        }
      }

      in "getLinePayResult" -> {
        if (context == null) {
          result.error("", "context is null", "")
        } else {
          getLinePayResult {
            result.success(it)
          }
        }
      }

      in "preparePaymentData" -> {
        //取得allowedNetworks
        val allowedNetworks: ArrayList<TPDCard.CardType> = ArrayList()
        val cardTypeMap = mapOf(
                Pair(0, TPDCard.CardType.Unknown),
                Pair(1, TPDCard.CardType.JCB),
                Pair(2, TPDCard.CardType.Visa),
                Pair(3, TPDCard.CardType.MasterCard),
                Pair(4, TPDCard.CardType.AmericanExpress),
                Pair(5, TPDCard.CardType.UnionPay)
        )

        val networks: List<Int>? = call.argument("allowedNetworks")
        for (i in networks!!) {
          val type = cardTypeMap[i]
          type?.let { allowedNetworks.add(it) }
        }

        //取得allowedAuthMethods
        val allowedAuthMethods: MutableList<TPDCard.AuthMethod> = mutableListOf()
        val authMethodMap = mapOf(
                Pair(0, TPDCard.AuthMethod.PanOnly),
                Pair(1, TPDCard.AuthMethod.Cryptogram3DS)
        )
        val authMethods: List<Int>? = call.argument("allowedAuthMethods")
        for (i in authMethods!!) {
          val type = authMethodMap[i]
          type?.let { allowedAuthMethods.add(it) }
        }

        val merchantName: String? = call.argument("merchantName")
        val isPhoneNumberRequired: Boolean? = call.argument("isPhoneNumberRequired")
        val isShippingAddressRequired: Boolean? = call.argument("isShippingAddressRequired")
        val isEmailRequired: Boolean? = call.argument("isPhoneNumberRequired")

        preparePaymentData(allowedNetworks.toTypedArray(), allowedAuthMethods.toTypedArray(), merchantName, isPhoneNumberRequired, isShippingAddressRequired, isEmailRequired)
      }

      in "requestPaymentData" -> {
        val totalPrice: String? = call.argument("totalPrice")
        val currencyCode: String? = call.argument("currencyCode")
        requestPaymentData(totalPrice, currencyCode)
      }

      in "getGooglePayPrime" -> {
        getGooglePayPrime()
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
  }

  //設置Tappay環境
  private fun setupTappay(appId: Int?, appKey: String?, serverType: String?, errorMessage: (String) -> (Unit)) {
    var message = ""

    if (appId == 0 || appId == null) {
      message += "appId error"
    }

    if (appKey.isNullOrEmpty()) {
      message += "/appKey error"
    }

    if (serverType.isNullOrEmpty()) {
      message += "/serverType error"
    }

    if (message.isNotEmpty()) {
      errorMessage(message)
      return
    }

    val st: TPDServerType = if (serverType == "sandBox") (TPDServerType.Sandbox) else (TPDServerType.Production)

    TPDSetup.initInstance(context, appId!!, appKey, st)
  }

  //檢查信用卡的有效性
  private fun isCardValid(cardNumber: String?, dueMonth: String?, dueYear: String?, ccv: String?): Boolean {

    if (cardNumber.isNullOrEmpty()) {
      return false
    }

    if (dueMonth.isNullOrEmpty()) {
      return false
    }

    if (dueYear.isNullOrEmpty()) {
      return false
    }

    if (ccv.isNullOrEmpty()) {
      return false
    }

    val result = TPDCard.validate(StringBuffer(cardNumber), StringBuffer(dueMonth), StringBuffer(dueYear), StringBuffer(ccv))

    return result.isCCVValid && result.isCardNumberValid && result.isExpiryDateValid
  }

  //取得Prime
  private fun getPrime(cardNumber: String?, dueMonth: String?, dueYear: String?, ccv: String?, prime: (String) -> (Unit), failCallBack: (String) -> (Unit)) {

    if (cardNumber == null || dueMonth == null || dueYear == null || ccv == null) {
      failCallBack("{\"status\":\"\", \"message\":\"something is null\", \"prime\":\"\"}")
    }else{
      val cn = StringBuffer(cardNumber)
      val dm = StringBuffer(dueMonth)
      val dy = StringBuffer(dueYear)
      val cv = StringBuffer(ccv)
      val card = TPDCard(context, cn, dm, dy, cv).onSuccessCallback { tpPrime, _, _, _ ->
        prime("{\"status\":\"\", \"message\":\"\", \"prime\":\"$tpPrime\"}")
      }.onFailureCallback { status, message ->
        failCallBack("{\"status\":\"$status\", \"message\":\"$message\", \"prime\":\"\"}")
      }
      card.createToken("Unknown")
    }

  }

  //檢查是否有安裝Easy wallet
  private fun isEasyWalletAvailable(): Boolean {
    return TPDEasyWallet.isAvailable(context)
  }

  //取得Easy wallet prime
  private fun getEasyWalletPrime(universalLink: String?, prime: (String) -> (Unit), failCallBack: (String) -> (Unit)) {

    if (universalLink == null) {
      failCallBack("{\"status\":\"\", \"message\":\"universalLink is null\", \"prime\":\"\"}")
    }else{
      val easyWallet = TPDEasyWallet(context, universalLink)
      easyWallet.getPrime({ tpPrime -> prime("{\"status\":\"\", \"message\":\"\", \"prime\":\"$tpPrime\"}") }, { status, message -> failCallBack("{\"status\":\"$status\", \"message\":\"$message\", \"prime\":\"\"}") })
    }
  }

  //重導向至Easy wallet
  private fun redirectToEasyWallet(universalLink: String?, paymentUrl: String?, callBack: (String) -> (Unit)) {

    if (universalLink == null || paymentUrl == null) {
      callBack("{\"status\":\"something is null\", \"recTradeId\":\"\", \"orderNumber\":\"\", \"bankTransactionId\":\"\"}")
    }else{
      val easyWallet = TPDEasyWallet(context, universalLink)
      easyWallet.redirectWithUrl(paymentUrl)
      callBack("{\"status\":\"redirect successfully\", \"recTradeId\":\"\", \"orderNumber\":\"\", \"bankTransactionId\":\"\"}")
    }
  }

  //解析East wallet result
  private fun parseToEasyWalletResult(universalLink: String?, uri: String?, failCallBack: (String) -> (Unit), successCallBack: (String) -> (Unit)) {

    if (universalLink == null || uri == null) {
      failCallBack("{\"message\":\"universalLink or uri is null\"}")
    }else{
      val easyWallet = TPDEasyWallet(context, universalLink)
      val parsedUri = Uri.parse(uri)
      easyWallet.parseToEasyWalletResult(context, parsedUri, this.tpdEasyWalletResultListenerInterface)
      successCallBack("Wait for EasyWallet result")
    }
  }

  //取得line pay result
  private fun getEasyWalletResult(result: (String) -> (Unit)) {
    if (tpdEasyWalletResultListenerInterface.successResult == null) {
      tpdEasyWalletResultListenerInterface.failResult?.let { result(it) }
    } else {
      tpdEasyWalletResultListenerInterface.successResult?.let { result(it) }
    }
  }

  //檢查是否有安裝line pay
  private fun isLinePayAvailable(): Boolean {
    return TPDLinePay.isLinePayAvailable(context)
  }

  //取得line pay prime
  private fun getLinePayPrime(universalLink: String?, prime: (String) -> (Unit), failCallBack: (String) -> (Unit)) {

    if (universalLink == null) {
      failCallBack("{\"status\":\"\", \"message\":\"universalLink is null\", \"prime\":\"\"}")
    }else{
      val linePay = TPDLinePay(context, universalLink)
      linePay.getPrime({ tpPrime -> prime("{\"status\":\"\", \"message\":\"\", \"prime\":\"$tpPrime\"}") }, { status, message -> failCallBack("{\"status\":\"$status\", \"message\":\"$message\", \"prime\":\"\"}") })
    }
  }

  //重導向至line pay
  private fun redirectToLinePay(universalLink: String?, paymentUrl: String?, callBack: (String) -> (Unit)) {

    if (universalLink == null || paymentUrl == null) {
      callBack("{\"status\":\"something is null\", \"recTradeId\":\"\", \"orderNumber\":\"\", \"bankTransactionId\":\"\"}")
    }else{
      val linePay = TPDLinePay(context, universalLink)
      linePay.redirectWithUrl(paymentUrl)
      callBack("{\"status\":\"redirect successfully\", \"recTradeId\":\"\", \"orderNumber\":\"\", \"bankTransactionId\":\"\"}")
    }
  }

  //解析line pay result
  private fun parseToLinePayResult(universalLink: String?, uri: String?, failCallBack: (String) -> (Unit), successCallBack: (String) -> (Unit)) {

    if (universalLink == null || uri == null) {
      failCallBack("{\"message\":\"universalLink or uri is null\"}")
    }else{
      val linePay = TPDLinePay(context, universalLink)
      val parsedUri = Uri.parse(uri)
      linePay.parseToLinePayResult(context, parsedUri, this.tpdLinePayResultListenerInterface)
      successCallBack("Wait for LinePay result")
    }
  }

  //取得line pay result
  private fun getLinePayResult(result: (String) -> (Unit)) {
    if (tpdLinePayResultListenerInterface.successResult == null) {
      tpdLinePayResultListenerInterface.failResult?.let { result(it) }
    } else {
      tpdLinePayResultListenerInterface.successResult?.let { result(it) }
    }
  }

  //Google pay
  private fun preparePaymentData(allowedNetworks: Array<TPDCard.CardType>, allowedAuthMethods: Array<TPDCard.AuthMethod>?, merchantName: String?, isPhoneNumberRequired: Boolean?, isShippingAddressRequired: Boolean?, isEmailRequired: Boolean?) {
    tpdMerchant.supportedNetworks = allowedNetworks
    tpdMerchant.supportedAuthMethods = allowedAuthMethods
    tpdMerchant.merchantName = merchantName
    if (isPhoneNumberRequired != null) {
      tpdConsumer.isPhoneNumberRequired = isPhoneNumberRequired
    }
    if (isShippingAddressRequired != null) {
      tpdConsumer.isShippingAddressRequired = isShippingAddressRequired
    }
    if (isEmailRequired != null) {
      tpdConsumer.isEmailRequired = isEmailRequired
    }

    if (this.activity != null) {
      tpdGooglePay = TPDGooglePay(this.activity, tpdMerchant, tpdConsumer)
      tpdGooglePay!!.isGooglePayAvailable(this.tpdGooglePayListenerInterfaceInterface)
    } else {
      Log.d("preparePaymentData", "activity is null")
    }
  }

  //request payment data
  private fun requestPaymentData(totalPrice: String?, currencyCode: String?) {
    tpdGooglePay?.requestPayment(TransactionInfo.newBuilder()
            .setTotalPriceStatus(WalletConstants.TOTAL_PRICE_STATUS_FINAL)
            .setTotalPrice(totalPrice!!)
            .setCurrencyCode(currencyCode!!)
            .build(), LOAD_PAYMENT_DATA_REQUEST_CODE);
  }

  //get google pay prime
  private fun getGooglePayPrime() {
    Log.d("getGooglePayPrime", "paymentData: $paymentData")
    tpdGooglePay?.getPrime(paymentData, tpdGooglePayListenerInterfaceInterface, tpdGooglePayListenerInterfaceInterface)
  }

}
