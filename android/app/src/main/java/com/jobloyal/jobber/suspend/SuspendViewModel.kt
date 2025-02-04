package com.jobloyal.jobber.suspend

import android.app.Application
import androidx.lifecycle.ViewModel
import com.jobloyal.jobber.main.requests.JobberRequestsViewModel
import com.jobloyal.jobber.model.status.GetLocationModel
import com.jobloyal.jobber.model.suspend.SuspendModel
import com.jobloyal.network.CommonApiService
import com.jobloyal.network.Http.HttpClient
import com.jobloyal.network.JobberApiService
import com.jobloyal.utility.Const.Companion.getIsJobberApp
import com.jobloyal.utility.RxViewModel
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import io.reactivex.subjects.BehaviorSubject
import java.text.SimpleDateFormat
import java.util.*

class SuspendViewModel (val app: Application) : RxViewModel(app) {

    val detail : BehaviorSubject<SuspendModel> = BehaviorSubject.create()

    fun getToday() : String {
        val calendar = Calendar.getInstance()
        val dateFormat = SimpleDateFormat("EEE, MMM d", Locale.getDefault());
        return dateFormat.format(calendar.time);
    }

    fun getDetail () {
        subscribe(
            HttpClient.buildRx<CommonApiService>(context = getApplication())
                .getDetailOfSuspend(if (app.getIsJobberApp() == true) "jobber" else "user").subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    ifSuccess(it) {
                        it?.let {detail.onNext(it) }
                    }
                }, {

                })
        )
    }
}