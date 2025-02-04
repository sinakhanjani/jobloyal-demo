package com.jobloyal.jobber.addservice.search

import android.app.Application
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.jobloyal.jobber.model.addservice.JobberSearchServiceRequest
import com.jobloyal.jobber.model.addservice.SearchServiceModel
import com.jobloyal.network.Http.HttpClient
import com.jobloyal.network.JobberApiService
import com.jobloyal.utility.RxViewModel
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.Disposable
import io.reactivex.schedulers.Schedulers
import io.reactivex.subjects.BehaviorSubject

class SearchToAddServiceViewModel(app : Application) : RxViewModel(app) {

    val services : BehaviorSubject<List<SearchServiceModel>> = BehaviorSubject.create()
    var waiting = MutableLiveData<Boolean>()
    var jobId : String? = null
    var disposable : Disposable? = null
    var searchedService : String? = null

    fun getAllServices () {
        waiting.value = true
        disposable =
            HttpClient.buildRx<JobberApiService>(context = getApplication())
                .getAllServiceOnJob(JobberSearchServiceRequest(job_id =  jobId)).subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    waiting.value = false
                    ifSuccess(it) { service ->
                        service?.items?.let {
                            services.onNext(it)
                        }
                    }
                }, {
                    waiting.value = false
                })
    }

    fun searchServiceByName (title : String) {
        waiting.value = true
        disposable =
            HttpClient.buildRx<JobberApiService>(context = getApplication())
                .searchService(JobberSearchServiceRequest(jobId, title)).subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    waiting.value = false
                    ifSuccess(it) { service ->
                        searchedService = title
                        service?.items?.let {
                            services.onNext(it)
                        }
                    }
                }, {
                    waiting.value = false
                })

    }

    override fun onCleared() {
        super.onCleared()
        disposable?.dispose()
    }
}