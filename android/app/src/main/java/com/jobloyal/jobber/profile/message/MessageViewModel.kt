package com.jobloyal.jobber.profile.message

import android.app.Application
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.jobloyal.jobber.model.message.MessageModel
import com.jobloyal.jobber.model.message.SendMessageRequestModel
import com.jobloyal.jobber.model.profile.edit.CompleteProfileModel
import com.jobloyal.network.CommonApiService
import com.jobloyal.network.Http.HttpClient
import com.jobloyal.network.JobberApiService
import com.jobloyal.utility.Const
import com.jobloyal.utility.Const.Companion.getIsJobberApp
import com.jobloyal.utility.RxViewModel
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import io.reactivex.subjects.BehaviorSubject

class MessageViewModel(val app: Application) : RxViewModel(app) {

    val waiting = MutableLiveData<Boolean>()
    val messages : BehaviorSubject<List<MessageModel>> = BehaviorSubject.create()

    fun getAllMessages () {
        waiting.value = true
        subscribe(
            HttpClient.buildRx<CommonApiService>(context = getApplication())
                .getMessages(if (app.getIsJobberApp() == true) "jobber" else "user")
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    waiting.value = false
                    ifSuccess(it) {
                        it?.items?.let { messages.onNext(it) }
                    }
                }, {
                    waiting.value = false
                })
        )
    }

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

                    }
                }, {
                    waiting.value = false
                })
        )
    }
}