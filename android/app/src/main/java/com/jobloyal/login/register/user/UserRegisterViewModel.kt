package com.jobloyal.login.register.user

import android.app.Application
import android.content.Context
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.jobloyal.login.model.register.JobberRegisterRequestModel
import com.jobloyal.login.register.jobber.RegisterJobberViewModel
import com.jobloyal.network.Http.HttpClient
import com.jobloyal.network.JobberApiService
import com.jobloyal.network.UserApiService
import com.jobloyal.user.model.login.UserRegisterRequestModel
import com.jobloyal.utility.Const
import com.jobloyal.utility.RxViewModel
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import java.util.*

class UserRegisterViewModel(val app: Application) : RxViewModel(app) {

    var token : String? = null
    var firstName = ""
    var lastName = ""
    var email = ""
    var address = ""
    var gender : Boolean? = null
    var birthday : String? = null
    var waiting = MutableLiveData<Boolean>()

    fun register () {
        var region = "en"
        val lang = Locale.getDefault().language
        if (lang == "ch" || lang == "fr") region = "fr"
        Const.registerLanguage(app, region)
        waiting.value = true
        subscribe(
            HttpClient.buildRx<UserApiService>(context = getApplication())
                .register(UserRegisterRequestModel(address,birthday,email,lastName,gender,firstName, region), "Bearer ${token}").subscribeOn(
                    Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    waiting.value = false
                    ifSuccess(it) {
                        updateTokenPreferences(it?.token ?: "")
                        navigate.value = RegisterJobberViewModel.NavigateRegisterJobberViewModel.NextToApp.ordinal
                    }
                }, {
                    waiting.value = false
                })
        )
    }

    private fun updateTokenPreferences (token : String) {
        app.getSharedPreferences("settings", Context.MODE_PRIVATE)
            .edit()
            .putString("token", token)
            .putBoolean("isJobberApp", false)
            .apply()
        Const.getToken(app, true)
    }
}