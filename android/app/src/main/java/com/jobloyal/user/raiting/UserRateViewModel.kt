package com.jobloyal.user.raiting

import android.app.Application
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.jobloyal.network.Http.HttpClient
import com.jobloyal.network.UserApiService
import com.jobloyal.user.model.comment.SubmitCommentRequestModel
import com.jobloyal.utility.RxViewModel
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers

class UserRateViewModel (app: Application) : RxViewModel(app) {

    var comment : String? = null
    var rate : Int? = null
    var waiting = MutableLiveData<Boolean>()

    fun submitComment () {
        waiting.value = true
        subscribe(
            HttpClient.buildRx<UserApiService>(context = getApplication())
                .submitComment(SubmitCommentRequestModel(comment, rate)).subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    waiting.value = false
                    ifSuccess(it) { jobs ->
                        navigate.value = 1
                    }
                }, {
                    waiting.value = false
                })
        )
    }
}