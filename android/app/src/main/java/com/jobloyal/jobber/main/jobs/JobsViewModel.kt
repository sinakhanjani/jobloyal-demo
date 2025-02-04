package com.jobloyal.jobber.main.jobs

import android.app.Application
import androidx.lifecycle.MutableLiveData
import com.jobloyal.jobber.main.requests.JobberRequestsViewModel
import com.jobloyal.jobber.model.MyJobModel
import com.jobloyal.jobber.model.status.GetLocationModel
import com.jobloyal.jobber.model.status.UpdateLocationRequestModel
import com.jobloyal.jobber.model.status.daily.ChangeStatusJobOfJobberRequestModel
import com.jobloyal.login.model.login.CheckOtpRequestModel
import com.jobloyal.login.verification.LoginVerificationViewModel
import com.jobloyal.network.CommonApiService
import com.jobloyal.network.Http.HttpClient
import com.jobloyal.network.JobberApiService
import com.jobloyal.utility.RxViewModel
import io.reactivex.Single
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import io.reactivex.subjects.BehaviorSubject
import java.text.SimpleDateFormat
import java.util.*

class JobsViewModel(app : Application) : RxViewModel(app) {

    val allMyJobs : BehaviorSubject<List<MyJobModel>> = BehaviorSubject.create()
    val location : BehaviorSubject<GetLocationModel> = BehaviorSubject.create()
    var waiting = MutableLiveData<Boolean>()
    var waitingForUpdateLocation = MutableLiveData<Boolean>()

    fun getMyJobs () {
        waiting.value = true
        subscribe(
            HttpClient.buildRx<JobberApiService>(context = getApplication())
                .getMyJobs().subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    waiting.value = false
                    ifSuccess(it) { jobs ->
                        jobs?.items?.let {
                            allMyJobs.onNext(it)
                        }
                    }
                }, {
                    waiting.value = false
                })
        )
    }

    fun updateLocation (lat :Double, lng: Double) {
        waitingForUpdateLocation.value = true
        subscribe(
            HttpClient.buildRx<JobberApiService>(context = getApplication())
                .updateLocation(UpdateLocationRequestModel(lat.toString(), lng.toString())).subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    waitingForUpdateLocation.value = false
                    ifSuccess(it) {
                        if (it != null) {
                            JobberRequestsViewModel.currentJobberLocation = it
                            JobberRequestsViewModel.backgroundImageMap = null
                            location.onNext(it)
                        }
                    }
                }, {
                    waitingForUpdateLocation.value = false
                })
        )
    }

    fun getLastLocation () {
        subscribe(
            HttpClient.buildRx<JobberApiService>(context = getApplication())
                .getLastLocation().subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    ifSuccess(it) {
                        if (it != null) {
                            JobberRequestsViewModel.currentJobberLocation = it
                            JobberRequestsViewModel.backgroundImageMap = null
                            location.onNext(it)
                        }
                        else {
                            location.onNext(GetLocationModel())
                        }
                    }
                }, {

                })
        )
    }

    fun changeStateOfJob (online : Boolean,model : MyJobModel) =
        Single.create<MyJobModel> {single ->
        subscribe(
            HttpClient.buildRx<JobberApiService>(context = getApplication())
                .changeStatusJobOfJobber(ChangeStatusJobOfJobberRequestModel(model.job_id, if (online) "online" else "offline")).subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    ifSuccess(it) {
                        model.updateModel(it?.status, it?.createdAt)
                        single.onSuccess(model)
                    }
                }, {

                })
        )
    }

    fun getToday() : String {
        val calendar = Calendar.getInstance()
        val dateFormat = SimpleDateFormat("EEE, MMM d", Locale.getDefault());
        return dateFormat.format(calendar.time);
    }
}