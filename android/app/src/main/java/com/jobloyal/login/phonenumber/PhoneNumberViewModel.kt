package com.jobloyal.login.phonenumber

import android.app.Application
import android.util.Log
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModel
import com.jobloyal.R
import com.jobloyal.login.model.login.LoginRequestModel
import com.jobloyal.network.CommonApiService
import com.jobloyal.network.Http.HttpClient
import com.jobloyal.utility.RxViewModel
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers

class PhoneNumberViewModel(app: Application) : RxViewModel(app) {

    var phoneNumber = ""
    var waiting = MutableLiveData<Boolean>()

    fun sendOTP () {
        waiting.value = true
        val phone = phoneNumber.replace("(","").replace(")","").replace("-","").replace(" ","")
        subscribe(
            HttpClient.buildRx<CommonApiService>(context = getApplication())
                .sendOTP(LoginRequestModel(phone)).subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    waiting.value = false
                    ifSuccess(it) {
                        navigate.value = 1 //means next
                    }
                }, {
                    waiting.value = false
                })
        )
    }
}