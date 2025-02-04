package com.jobloyal.jobber.main.report.service

import android.app.Application
import androidx.lifecycle.ViewModel
import com.jobloyal.jobber.model.report.PaginationModel
import com.jobloyal.jobber.model.request.Service
import com.jobloyal.network.Http.HttpClient
import com.jobloyal.network.JobberApiService
import com.jobloyal.utility.RxViewModel
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import io.reactivex.subjects.BehaviorSubject

class ServicesReportViewModel (app: Application) : RxViewModel(app) {

    var requestId : String? = null
    val services : BehaviorSubject<List<Service>> = BehaviorSubject.create()

    fun getServicesOfRequest () {
        subscribe(
            HttpClient.buildRx<JobberApiService>(context = getApplication())
                .getReport(requestId).subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    ifSuccess(it) {
                        it?.services?.let {services.onNext(it) }
                    }
                }, {
                })
        )
    }

}