package com.jobloyal.jobber.job_page

import android.app.Application
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.jobloyal.jobber.model.addservice.JobberSearchServiceRequest
import com.jobloyal.jobber.model.addservice.SearchServiceModel
import com.jobloyal.jobber.model.job_page.DeleteServiceFromJob
import com.jobloyal.jobber.model.job_page.JobPageModel
import com.jobloyal.network.Http.HttpClient
import com.jobloyal.network.JobberApiService
import com.jobloyal.utility.RxViewModel
import io.reactivex.Single
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import io.reactivex.subjects.BehaviorSubject

class JobPageViewModel(app : Application) : RxViewModel(app) {

    val jobPage : BehaviorSubject<JobPageModel> = BehaviorSubject.create()
    var waiting = MutableLiveData<Boolean>()
    var jobId : String? = null
    var isNewJob : Boolean? = false
    var first = true

    fun getAllServices () {
        waiting.value = true
        subscribe(
            HttpClient.buildRx<JobberApiService>(context = getApplication())
                .getJobPage(JobberSearchServiceRequest(job_id = jobId)).subscribeOn(
                    Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    waiting.value = false
                    ifSuccess(it) { response ->
                        response?.let {  jobPage.onNext(it) }
                    }
                }, {
                    waiting.value = false
                }))
    }

    fun deleteService (serviceID : String?) = Single.create<Boolean> {  single ->
        subscribe(
            HttpClient.buildRx<JobberApiService>(context = getApplication())
                .deleteServiceFromJob(DeleteServiceFromJob(serviceID)).subscribeOn(
                    Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    ifSuccessOrNot(it, { response ->
                        single.onSuccess(true)
                    }) {
                        single.onSuccess(false)
                        true
                    }
                }, {
                }))
    }
}