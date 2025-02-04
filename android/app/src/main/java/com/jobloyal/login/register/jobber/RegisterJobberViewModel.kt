package com.jobloyal.login.register.jobber

import android.app.Application
import android.content.Context
import android.util.Log
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.jobloyal.login.model.register.CheckAvailableIdentifierRequestModel
import com.jobloyal.login.model.register.JobberRegisterRequestModel
import com.jobloyal.network.CommonApiService
import com.jobloyal.network.Http.HttpClient
import com.jobloyal.network.JobberApiService
import com.jobloyal.utility.Const
import com.jobloyal.utility.RxViewModel
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.Disposable
import io.reactivex.schedulers.Schedulers
import java.util.*

class RegisterJobberViewModel(val app : Application) : RxViewModel(app) {

    var token : String? = null
    var firstName = ""
    var lastName = ""
    var zipCode = ""
    var identifier : String? = null
    var waiting = MutableLiveData<Boolean>()
    var waitingForIdentifierCheck = MutableLiveData<Boolean>()
    var disposable : Disposable? = null
    enum class NavigateRegisterJobberViewModel {IdAlreadyExist,IdIsAvailable, NextToApp}

    fun register () {
        var region = "en"
        val lang = Locale.getDefault().language
        if (lang == "ch" || lang == "fr") region = "fr"
        Const.registerLanguage(app, region)
        waiting.value = true
        subscribe(
            HttpClient.buildRx<JobberApiService>(context = getApplication())
                .register(JobberRegisterRequestModel(firstName,lastName,zipCode, identifier,region), "Bearer ${token}").subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    waiting.value = false
                    ifSuccess(it) {
                        updateTokenPreferences(it?.token ?: "")
                        navigate.value = NavigateRegisterJobberViewModel.NextToApp.ordinal
                    }
                }, {
                    waiting.value = false
                })
        )
    }

    fun checkIdentifier (identifier : String) {
        waitingForIdentifierCheck.value = true
        disposable = HttpClient.buildRx<JobberApiService>(context = getApplication())
                .checkAvailableId(CheckAvailableIdentifierRequestModel(identifier)).subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    waitingForIdentifierCheck.value = false
                    ifSuccessOrNot(it, {
                        this.identifier = identifier
                        navigate.value = NavigateRegisterJobberViewModel.IdIsAvailable.ordinal
                    },{
                        this.identifier = null
                        navigate.value = NavigateRegisterJobberViewModel.IdAlreadyExist.ordinal
                        false
                    })
                }, {
                    waitingForIdentifierCheck.value = false
                })

    }

    private fun updateTokenPreferences (token : String) {
        app.getSharedPreferences("settings", Context.MODE_PRIVATE)
            .edit()
            .putString("token", token)
            .putBoolean("isJobberApp", true)
            .apply()
        Const.getToken(app, true)
    }

}