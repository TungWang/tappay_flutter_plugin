package com.tungwang.tappayflutterplugin

import android.content.Context
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import tech.cherri.tpdirect.api.TPDCard
import tech.cherri.tpdirect.api.TPDServerType
import tech.cherri.tpdirect.api.TPDSetup

/** TappayflutterpluginPlugin */
public class TappayflutterpluginPlugin: FlutterPlugin, MethodCallHandler {
  private var context: Context? = null

  constructor()

  constructor(context: Context) {
    this.context = context
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    val channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "tappayflutterplugin")
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

    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else if (call.method == "setupTappay") {

      if (context == null) {
        result.error("", "context is null", "")
      }else{

        val appId: Int? = call.argument("appId")
        val appKey: String? = call.argument("appKey")
        val serverType: String? = call.argument("serverType")
        val cardNumber: String? = call.argument("cardNumber")
        val dueMonth: String? = call.argument("dueMonth")
        val dueYear: String? = call.argument("dueYear")
        val ccv: String? = call.argument("ccv")

        if (appId != null && appKey != null && serverType != null && cardNumber != null && dueMonth != null && dueYear != null && ccv != null) {

          var st: TPDServerType = TPDServerType.Sandbox
          if (serverType != "sandBox") {
            st = TPDServerType.Production
          }

          TPDSetup.initInstance(context, appId, appKey, st)

          val cn = StringBuffer(cardNumber)
          val dm = StringBuffer(dueMonth)
          val dy = StringBuffer(dueYear)
          val cv = StringBuffer(ccv)
          val card = TPDCard(context, cn, dm, dy, cv).onSuccessCallback { prime, _, _ ->
            result.success(prime)
          }.onFailureCallback { status, message ->
            result.error(status.toString(), message, "errorDetail")
          }
          card.createToken("Unknown")

        }else{
          result.error("", "something is null", "")
        }

      }

    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
  }
}
