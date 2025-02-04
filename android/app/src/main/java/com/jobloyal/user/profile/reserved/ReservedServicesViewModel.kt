package com.jobloyal.user.profile.reserved

import android.app.Application
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.jobloyal.jobber.model.report.PaginationModel
import com.jobloyal.network.Http.HttpClient
import com.jobloyal.network.UserApiService
import com.jobloyal.user.model.profile.UserProfileModel
import com.jobloyal.user.model.profile.reserved.ReservedServicesModel
import com.jobloyal.utility.RxViewModel
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import io.reactivex.subjects.BehaviorSubject

class ReservedServicesViewModel(app : Application) : RxViewModel(app) {

    val services : BehaviorSubject<List<ReservedServicesModel>> = BehaviorSubject.create()
    val waiting = MutableLiveData<Boolean>()
    var accepted : Boolean = true
    private val limit = 10
    var page = 0

    fun getServices () {
        waiting.value = true
        val http = HttpClient.buildRx<UserApiService>(context = getApplication())
        var call = if (accepted) http.getReservedServices(PaginationModel(limit, page)) else http.getCanceledServices(PaginationModel(limit, page))
        call = call.subscribeOn(Schedulers.io())
            .observeOn(AndroidSchedulers.mainThread())
        subscribe(call.subscribe({
                    waiting.value = false
                    ifSuccess(it) {
                        it?.items?.let {
                            services.onNext(it)
                        }
                    }
                }, {
                    waiting.value = false
                })
        )
    }
}