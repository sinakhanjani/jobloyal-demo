package com.jobloyal.jobber.profile.message.send

import android.app.Application
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.jobloyal.jobber.model.message.SendMessageRequestModel
import com.jobloyal.network.CommonApiService
import com.jobloyal.network.Http.HttpClient
import com.jobloyal.utility.Const.Companion.getIsJobberApp
import com.jobloyal.utility.RxViewModel
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers

class SendMessageViewModel (val app: Application) : RxViewModel(app){

    val waiting = MutableLiveData<Boolean>()

    fun sendNewMessage (subject : String, message : String) {
        waiting.value = true
        subscribe(
            HttpClient.buildRx<CommonApiService>(context = getApplication())
                .postMessage(if (app.getIsJobberApp() == true) "jobber" else "user", SendMessageRequestModel(message, subject))
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    waiting.value = false
                    ifSuccess(it) {
                        navigate.value = 1
                    }
                }, {
                    waiting.value = false
                })
        )
    }
}