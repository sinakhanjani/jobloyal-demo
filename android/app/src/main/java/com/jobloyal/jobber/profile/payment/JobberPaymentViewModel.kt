package com.jobloyal.jobber.profile.payment

import android.app.Application
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.jobloyal.jobber.model.profile.edit.PaymentEditModel
import com.jobloyal.network.Http.HttpClient
import com.jobloyal.network.JobberApiService
import com.jobloyal.utility.RxViewModel
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers

class JobberPaymentViewModel(app: Application) : RxViewModel(app) {

    var waiting = MutableLiveData<Boolean>()

    fun save (period: Int,iban : String) {
        waiting.value = true
        subscribe(
            HttpClient.buildRx<JobberApiService>(context = getApplication())
                .editPayment(PaymentEditModel(period = period, iban = iban)).subscribeOn(
                    Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    waiting.value = false
                    ifSuccess(it) { response ->
                        navigate.value = 1
                    }
                }, {
                    waiting.value = false
                }))
    }
}