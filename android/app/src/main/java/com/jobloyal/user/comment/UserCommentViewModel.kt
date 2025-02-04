package com.jobloyal.user.comment

import android.app.Application
import androidx.lifecycle.MutableLiveData
import com.jobloyal.network.Http.HttpClient
import com.jobloyal.network.UserApiService
import com.jobloyal.user.model.comment.GetCommentsRequestModel
import com.jobloyal.user.model.jobber.page.Comment
import com.jobloyal.utility.RxViewModel
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import io.reactivex.subjects.BehaviorSubject

class UserCommentViewModel(val app: Application) : RxViewModel(app) {

    var jobId: String? = null
    var jobberId: String? = null
    val limit = 10
    var page = 0
    var waiting = MutableLiveData<Boolean>()
    val comments: BehaviorSubject<List<Comment>> = BehaviorSubject.create()

    fun getComments() {
        waiting.value = true
        subscribe(
            HttpClient.buildRx<UserApiService>(context = getApplication())
                .getCommentsOfJob(GetCommentsRequestModel(jobId, jobberId, limit, page))
                .subscribeOn(
                    Schedulers.io()
                )
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    waiting.value = false
                    ifSuccess(it) { response ->
                        response?.items?.let { comments.onNext(it) }
                    }
                }, {
                    waiting.value = false
                })
        )
    }
}