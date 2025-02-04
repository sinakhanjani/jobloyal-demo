package com.jobloyal.jobber.profile.turnover

import android.app.Application
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.jobloyal.jobber.model.turnover.TurnoverModel
import com.jobloyal.network.CommonApiService
import com.jobloyal.network.Http.HttpClient
import com.jobloyal.network.JobberApiService
import com.jobloyal.utility.Const.Companion.getIsJobberApp
import com.jobloyal.utility.RxViewModel
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import io.reactivex.subjects.BehaviorSubject

class TurnoverViewModel(app: Application) : RxViewModel(app) {

    val waiting = MutableLiveData<Boolean>()
    val turnovers : BehaviorSubject<List<TurnoverModel>> = BehaviorSubject.create()

    fun getAllTurnover () {
        waiting.value = true
        subscribe(
            HttpClient.buildRx<JobberApiService>(context = getApplication())
                .getTurnover()
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    waiting.value = false
                    ifSuccess(it) {
                        it?.items?.let { turnovers.onNext(it) }
                    }
                }, {
                    waiting.value = false
                })
        )
    }
}