package com.jobloyal.user.main.jobbers

import android.app.Application
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.jobloyal.jobber.model.category.JobsByCategoryIDRequestModel
import com.jobloyal.network.Http.HttpClient
import com.jobloyal.network.UserApiService
import com.jobloyal.user.model.jobber.FindJobberRequestModel
import com.jobloyal.user.model.jobber.NearJobberModel
import com.jobloyal.utility.RxViewModel
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import io.reactivex.subjects.BehaviorSubject
import io.reactivex.subjects.ReplaySubject

class JobbersListViewModel(app: Application) : RxViewModel(app) {

    var jobId : String? = null
    var lat : Double? = null
    var long : Double? = null
    var serviceId : String? = null
    var waiting = MutableLiveData<Boolean>()
    val jobbers : ReplaySubject<List<NearJobberModel>> = ReplaySubject.create()
    var page = 0
    val limit = 10
    var loaded = false


    fun getJobbersByJobId () {
        waiting.value = true
        subscribe(
            HttpClient.buildRx<UserApiService>(context = getApplication())
                .findByJob(FindJobberRequestModel(jobId,lat,long,page,null)).subscribeOn(
                    Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    waiting.value = false
                    ifSuccess(it) { response ->
                        loaded = true
                        response?.items?.let {
                            this.jobbers.onNext(it)
                        }
                    }
                }, {
                    waiting.value = false
                })
        )
    }

    fun getJobbersByServiceId () {
        waiting.value = true
        subscribe(
            HttpClient.buildRx<UserApiService>(context = getApplication())
                .findJobByService(FindJobberRequestModel(jobId,lat,long,page,serviceId)).subscribeOn(
                    Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    waiting.value = false
                    ifSuccess(it) { response ->
                        loaded = true
                        response?.items?.let {
                            this.jobbers.onNext(it)
                        }
                    }
                }, {
                    waiting.value = false
                })
        )
    }
}