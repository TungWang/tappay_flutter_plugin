package com.tungwang.tappayflutterplugin

import android.content.Context
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import tech.cherri.tpdirect.api.*
import tech.cherri.tpdirect.callback.TPDEasyWalletGetPrimeSuccessCallback
import tech.cherri.tpdirect.callback.TPDGetPrimeFailureCallback

/** TappayflutterpluginPlugin */
public class TappayflutterpluginPlugin: FlutterPlugin, MethodCallHandler {
  private var context: Context? = null

  constructor()

  constructor(context: Context) {
    this.context = context
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    val channel = MethodChannel(flutterPluginBinding.binaryMessenger, "tappayflutterplugin")
    val plugin = flutterPluginBinding.applicationContext
    channel.setMethodCallHandler(TappayflutterpluginPlugin(plugin))
  }

  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "tappayflutterplugin")
      val plugin = TappayflutterpluginPlugin(registrar.context())
      channel.setMethodCallHandler(plugin)

    }
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {

    when (call.method) {
      in "setupTappay" -> {
        if (context == null) {
          result.error("", "context is null", "")
        }else{
          val appId: Int? = call.argument("appId")
          val appKey: String? = call.argument("appKey")
          val serverType: String? = call.argument("serverType")
          setupTappay(appId, appKey, serverType, errorMessage = {result.error("", it, "")})
        }
      }

      in "isCardValid" -> {
        if (context == null) {
          result.error("", "context is null", "")
        }else{
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
        }else{
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
        }else{
          result.success(isEasyWalletAvailable())
        }
      }

      in "getEasyWalletPrime" -> {
        if (context == null) {
          result.error("", "context is null", "")
        }else {
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
        }else{
          val universalLink: String? = call.argument("universalLink")
          val paymentUrl: String? = call.argument("paymentUrl")
          redirectToEasyWallet(universalLink, paymentUrl, callBack = {
            result.success(it)
          })
        }
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
      easyWallet.getPrime({ tpPrime -> prime("{\"status\":\"\", \"message\":\"\", \"prime\":\"$tpPrime\"}")}, { status, message -> failCallBack("{\"status\":\"$status\", \"message\":\"$message\", \"prime\":\"\"}")})
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
}
