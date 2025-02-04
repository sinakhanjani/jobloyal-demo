package com.jobloyal.user.invoice

import android.app.Application
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.jobloyal.jobber.model.addservice.CreateNewServiceRequestModel
import com.jobloyal.network.Http.HttpClient
import com.jobloyal.network.UserApiService
import com.jobloyal.user.model.jobber.GetJobberPageRquestModel
import com.jobloyal.user.model.payment.GetPayInfoResultModel
import com.jobloyal.user.model.payment.UseWalletMode
import com.jobloyal.user.model.request.CreateNewRequestModel
import com.jobloyal.user.model.request.ServiceInCreateNewRequest
import com.jobloyal.utility.RxViewModel
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import io.reactivex.subjects.BehaviorSubject

class UserInvoiceViewModel(app : Application) : RxViewModel(app) {

    val wallet : BehaviorSubject<Float> = BehaviorSubject.create()
    var services : List<ServiceInCreateNewRequest>? = null
    var jobberId : String? = null
    var latitude : Double? = null
    var longitiude : Double? = null
    var waiting = MutableLiveData<Boolean>()
    var payInfoResultModel : GetPayInfoResultModel? = null

    fun getWallet () {
        subscribe(
            HttpClient.buildRx<UserApiService>(context = getApplication())
                .getWalletCredit().subscribeOn(
                    Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    ifSuccess(it) { response ->
                        response?.credit?.let { it -> wallet.onNext(it) }
                    }
                }, {
                })
        )
    }

    fun sendRequest () {
        waiting.value = true
        subscribe(
            HttpClient.buildRx<UserApiService>(context = getApplication())
                .createNewRequest(CreateNewRequestModel(jobberId,latitude,longitiude,services)).subscribeOn(
                    Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    ifSuccessOrNot(it ,{ response ->
                        navigate.value = 1
                    }) {
                        waiting.value = false
                        true
                    }
                }, {
                    waiting.value = false
                })
        )
    }

    fun pay () {
        waiting.value = true
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
                            waiting.value = false
                        }
                    }) {
                        waiting.value = false
                        true
                    }
                }, {
                    waiting.value = false
                })
        )
    }
    fun checkPayment () {
        waiting.value = true
        subscribe(
            HttpClient.buildRx<UserApiService>(context = getApplication())
                .checkPay().subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    ifSuccessOrNot(it, { response ->
                        navigate.value = 2
                    }) {
                        waiting.value = false
                        true
                    }
                }, {
                    waiting.value = false
                })
        )
    }
}