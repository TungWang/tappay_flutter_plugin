package com.tungwang.tappayflutterplugin
import android.util.Log
import tech.cherri.tpdirect.callback.TPDGetPrimeFailureCallback
import tech.cherri.tpdirect.callback.TPDGooglePayGetPrimeSuccessCallback
import tech.cherri.tpdirect.callback.TPDGooglePayListener
import tech.cherri.tpdirect.callback.dto.TPDCardInfoDto
import tech.cherri.tpdirect.callback.dto.TPDMerchantReferenceInfoDto

class TPDGooglePayListenerInterface: TPDGooglePayListener, TPDGooglePayGetPrimeSuccessCallback, TPDGetPrimeFailureCallback {
    override fun onReadyToPayChecked(p0: Boolean, p1: String?) {
        Log.d("onReadyToPayChecked", "$p0 $p1")
    }

    override fun onSuccess(p0: String?, p1: TPDCardInfoDto?, p2: TPDMerchantReferenceInfoDto?) {
        Log.d("onSuccess", "$p0 $p1 $p2")
    }

    override fun onFailure(p0: Int, p1: String?) {
        Log.d("onFailure", "$p0 $p1")
    }
}