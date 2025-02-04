package com.jobloyal.user.jobber_page

import android.app.Application
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.jobloyal.jobber.model.category.CategoryModel
import com.jobloyal.network.Http.HttpClient
import com.jobloyal.network.UserApiService
import com.jobloyal.user.model.jobber.GetJobberPageRquestModel
import com.jobloyal.user.model.jobber.page.JobberPageModel
import com.jobloyal.user.model.payment.GetPayInfoResultModel
import com.jobloyal.user.model.payment.UseWalletMode
import com.jobloyal.user.model.service.SearchServiceModel
import com.jobloyal.utility.RxViewModel
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.Disposable
import io.reactivex.schedulers.Schedulers
import io.reactivex.subjects.BehaviorSubject

class JobberPageViewModel(app: Application) : RxViewModel(app) {

    var jobberId : String? = null
    var jobId : String? = null
    var lat : String? = null
    var lng : String? = null
    var jobberPage : BehaviorSubject<JobberPageModel> = BehaviorSubject.create()
    var waiting = MutableLiveData<Boolean>()
    var waitingOperation = MutableLiveData<Boolean>()
    var lastStatus : String? = null
    var payInfoResultModel : GetPayInfoResultModel? = null

    fun getJobberPage () {
        waiting.value = true
        subscribe(
            HttpClient.buildRx<UserApiService>(context = getApplication())
                .getJobberPage(GetJobberPageRquestModel(jobId, jobberId,lat,lng)).subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    waiting.value = false
                    ifSuccess(it) { response ->
                        response?.let { it1 -> this.jobberPage.onNext(it1) }
                    }
                }, {
                    waiting.value = false
                })
        )
    }

    fun getDetailOfLastRequest () {
        waiting.value = true
        subscribe(
            HttpClient.buildRx<UserApiService>(context = getApplication())
                .getLastRequestDetail().subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    waiting.value = false
                    ifSuccess(it) { response ->
                        jobberId = response?.id
                        jobId = response?.request?.job_id
                        response?.let { it1 ->
                            this.jobberPage.onNext(it1)
                            lastStatus = it1.request?.status
                        }
                    }
                }, {
                    waiting.value = false
                })
        )
    }

    fun cancel () {
        waitingOperation.value = true
        subscribe(
            HttpClient.buildRx<UserApiService>(context = getApplication())
                .cancelJob().subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    ifSuccessOrNot(it, { response ->
                        navigate.value = 2
                    }) {
                        waitingOperation.value = false
                        true
                    }
                }, {
                    waitingOperation.value = false
                })
        )
    }

    fun pay () {
        waitingOperation.value = true
        subscribe(
            HttpClient.buildRx<UserApiService>(context = getApplication())
                .payJob(UseWalletMode(use_wallet = true)).subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    ifSuccessOrNot(it, { response ->
                        if (response?.paid == true) {
                            navigate.value = 2
                        }
                        else {
                            payInfoResultModel = response
                            navigate.value = 3
                            waitingOperation.value = false
                        }
                    }) {
                        waitingOperation.value = false
                        true
                    }
                }, {
                    waitingOperation.value = false
                })
        )
    }

    fun checkPayment () {
        waitingOperation.value = true
        subscribe(
            HttpClient.buildRx<UserApiService>(context = getApplication())
                .checkPay().subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    ifSuccessOrNot(it, { response ->
                        navigate.value = 2
                    }) {
                        waitingOperation.value = false
                        true
                    }
                }, {
                    waitingOperation.value = false
                })
        )
    }

    fun verify () {
        waitingOperation.value = true
        subscribe(
            HttpClient.buildRx<UserApiService>(context = getApplication())
                .verifyJob().subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    ifSuccessOrNot(it, { response ->
                        navigate.value = 2
                    }) {
                        waitingOperation.value = false
                        true
                    }
                }, {
                    waitingOperation.value = false
                })
        )
    }
}