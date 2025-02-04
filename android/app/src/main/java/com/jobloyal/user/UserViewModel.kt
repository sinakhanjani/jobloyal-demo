package com.jobloyal.user

import android.app.Application
import android.content.Context
import android.os.Build
import android.provider.Settings
import android.util.Log
import androidx.lifecycle.MutableLiveData
import com.jobloyal.BuildConfig
import com.jobloyal.jobber.model.deivce_info.AddDeviceInfoModel
import com.jobloyal.jobber.model.request.detail.JobberRequestDetailModel
import com.jobloyal.jobber.model.update.UpdateResponseModel
import com.jobloyal.model.CheckUpdateRequest
import com.jobloyal.model.ResponseModel
import com.jobloyal.network.CommonApiService
import com.jobloyal.network.Http.HttpClient
import com.jobloyal.network.JobberApiService
import com.jobloyal.network.UserApiService
import com.jobloyal.user.model.jobber.page.JobberPageModel
import com.jobloyal.user.model.request.last.LastRequestStatusResponseModel
import com.jobloyal.utility.Const
import com.jobloyal.utility.RxViewModel
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import io.reactivex.subjects.BehaviorSubject


class UserViewModel(val app: Application) : RxViewModel(app) {

    var lastRequest: BehaviorSubject<ResponseModel<LastRequestStatusResponseModel>> =
        BehaviorSubject.create()
    var lastStatus: String? = null
    val suspendStatus: BehaviorSubject<Boolean> = BehaviorSubject.create()
    val update: BehaviorSubject<UpdateResponseModel> = BehaviorSubject.create()

    fun getLastRequestDetail() {
        subscribe(
            HttpClient.buildRx<UserApiService>(context = getApplication())
                .lastRequestStatus().subscribeOn(
                    Schedulers.io()
                )
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    ifSuccess(it) { response ->
                        lastRequest.onNext(it)
                    }
                }, {
                })
        )
    }
    fun sendFCMToken (token : String) {
        val id = Settings.Secure.getString(app.contentResolver,
            Settings.Secure.ANDROID_ID);
        subscribe(HttpClient.buildRx<UserApiService>(context = getApplication())
            .addDevice(
                AddDeviceInfoModel(device_id = id,"android","android-user", token)
            ).subscribeOn(Schedulers.io())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe({
                Const.setFCMSent(getApplication())
            },{}))
    }
    fun checkVersion() {
        subscribe(
            HttpClient.buildRx<CommonApiService>(context = getApplication())
                .checkUpdate(CheckUpdateRequest("android", false)).subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                   ifSuccess(it) {
                       it?.let {
                           if (it.version_code != null && it.version_code  > BuildConfig.VERSION_CODE) {
                               if (it.force == true) {
                                   update.onNext(it)
                               }
                               else if ((plusTime()) % (if (it.period ?: 1 == 0) 1 else  it.period ?: 1) == 0) {
                                   update.onNext(it)
                               }
                           }
                       }
                   }
                }, {
                })
        )
    }

    private fun plusTime () : Int {
        val preferences = app.getSharedPreferences("settings", Context.MODE_PRIVATE)
        val time = preferences
            .getInt("update_time", 0)
        preferences.edit().putInt("update_time", time + 1).apply()
        return time
    }
}