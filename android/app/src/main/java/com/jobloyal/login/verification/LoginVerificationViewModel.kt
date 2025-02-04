package com.jobloyal.login.verification

import android.app.Application
import android.content.Context
import android.util.Log
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.jobloyal.login.model.login.CheckOtpRequestModel
import com.jobloyal.login.model.login.LoginRequestModel
import com.jobloyal.model.ChangeRegionRequestModel
import com.jobloyal.network.CommonApiService
import com.jobloyal.network.Http.HttpClient
import com.jobloyal.utility.Const
import com.jobloyal.utility.RxViewModel
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import java.util.*

class LoginVerificationViewModel(val app: Application) : RxViewModel(app) {

    var phoneNumber = ""
    var waiting = MutableLiveData<Boolean>()
    enum class NavigateLoginVerificationViewModel {WrongCode, NextToApp,NextToRegister,ResetTimer}
    var isJobberApp = false
    var token : String? = null

    fun checkOTP (code : String) {
        waiting.value = true
        val phone = phoneNumber.replace("(","").replace(")","").replace("-","").replace(" ","")
        subscribe(
            HttpClient.buildRx<CommonApiService>(context = getApplication())
                .checkOtp(CheckOtpRequestModel(code,phone)).subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    ifSuccessOrNot(it,{
                        token = it?.token
                        getToken()
                    }, {
                        waiting.value = false
                        if (it.code == 103) navigate.value = NavigateLoginVerificationViewModel.WrongCode.ordinal
                        false
                    })
                }, {
                    waiting.value = false
                })
        )
    }

    fun resendOTP () {
        val phone = phoneNumber.replace("(","").replace(")","").replace("-","").replace(" ","")
        subscribe(
            HttpClient.buildRx<CommonApiService>(context = getApplication())
                .sendOTP(LoginRequestModel(phone))
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    ifSuccess(it) {
                        navigate.value = NavigateLoginVerificationViewModel.ResetTimer.ordinal
                    }
                }, {
                    navigate.value = NavigateLoginVerificationViewModel.ResetTimer.ordinal
                })
        )
    }

    private fun getToken () {
        var region = "en"
        val lang = Locale.getDefault().language
        if (lang == "ch" || lang == "fr") region = "fr"
        Const.registerLanguage(app, region)
        waiting.value = true
        subscribe(
            HttpClient.buildRx<CommonApiService>(context = getApplication())
                .getToken((if (isJobberApp) "jobber" else "user"), "Bearer $token",
                    ChangeRegionRequestModel(region)).subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    waiting.value = false
                    ifSuccessOrNot(it,{ data ->
                        if (data?.token != null) {
                            updateTokenPreferences(data.token,isJobberApp)
                            navigate.value = NavigateLoginVerificationViewModel.NextToApp.ordinal
                        }
                        else {
                            navigate.value = NavigateLoginVerificationViewModel.NextToRegister.ordinal
                        }

                    }, {
                        true
                    })
                }, {
                    waiting.value = false
                })
        )
    }

    private fun updateTokenPreferences (token : String,isJobberApp : Boolean) {
        app.getSharedPreferences("settings", Context.MODE_PRIVATE)
            .edit()
            .putString("token", token)
            .putBoolean("isJobberApp", isJobberApp)
            .apply()
        Const.getToken(app, true)
    }

}