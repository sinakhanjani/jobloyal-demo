package com.jobloyal.jobber.main.profile

import android.app.Application
import android.provider.Settings
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.jobloyal.jobber.model.deivce_info.AddDeviceInfoModel
import com.jobloyal.jobber.model.profile.JobberProfileModel
import com.jobloyal.network.Http.HttpClient
import com.jobloyal.network.JobberApiService
import com.jobloyal.network.UserApiService
import com.jobloyal.utility.RxViewModel
import io.reactivex.Single
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import io.reactivex.subjects.BehaviorSubject

class JobberProfileViewModel(val app: Application) : RxViewModel(app) {

    val profile : BehaviorSubject<JobberProfileModel> = BehaviorSubject.create()
    val waiting = MutableLiveData<Boolean>()

    fun getProfile () {
        waiting.value = true
        subscribe(
            HttpClient.buildRx<JobberApiService>(context = getApplication())
                .getProfile().subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    waiting.value = false
                    ifSuccess(it) {
                        it?.let {
                            profile.onNext(it)
                        }
                    }
                }, {
                    waiting.value = false
                })
        )
    }

    fun deleteDevice () = Single.create<Boolean> { single ->
        waiting.value = true
        val id = Settings.Secure.getString(app.contentResolver,
            Settings.Secure.ANDROID_ID);
        subscribe(
            HttpClient.buildRx<JobberApiService>(context = getApplication())
                .deleteDevice(AddDeviceInfoModel(device_id = id, null, null, null))
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    waiting.value = false
                    ifSuccessOrNot(it, {
                        single.onSuccess(true)
                    }) {
                        single.onSuccess(true)
                        false
                    }
                }, {
                    waiting.value = false
                })
        )
    }
}