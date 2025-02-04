package com.jobloyal.jobber.main.report

import android.app.Application
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.jobloyal.jobber.model.report.PaginationModel
import com.jobloyal.jobber.model.report.SingleReportModel
import com.jobloyal.jobber.model.status.GetLocationModel
import com.jobloyal.network.Http.HttpClient
import com.jobloyal.network.JobberApiService
import com.jobloyal.utility.RxViewModel
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import io.reactivex.subjects.BehaviorSubject
import io.reactivex.subjects.ReplaySubject

class JobberReportViewModel (app: Application) : RxViewModel(app) {

    val reports : ReplaySubject<List<SingleReportModel>> = ReplaySubject.create()
    var waiting = MutableLiveData<Boolean>()
    val count = 10
    var page = 0;
    var loaded = false;

    fun getReports () {
        waiting.value = true
        subscribe(
            HttpClient.buildRx<JobberApiService>(context = getApplication())
                .getReports(PaginationModel(page = page, limit = count)).subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    waiting.value = false
                    ifSuccess(it) { jobs ->
                        loaded = true;
                        jobs?.items?.let {
                            reports.onNext(it)
                        }
                    }
                }, {
                    waiting.value = false
                })
        )
    }
}