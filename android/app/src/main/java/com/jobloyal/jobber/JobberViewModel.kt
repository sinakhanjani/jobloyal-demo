package com.jobloyal.jobber

import android.app.Application
import android.content.Context
import android.provider.Settings
import com.google.gson.Gson
import com.google.gson.JsonSyntaxException
import com.jobloyal.BuildConfig
import com.jobloyal.jobber.model.MyJobModel
import com.jobloyal.jobber.model.deivce_info.AddDeviceInfoModel
import com.jobloyal.jobber.model.request.FCMCanceledRequest
import com.jobloyal.jobber.model.request.RequestModel
import com.jobloyal.jobber.model.request.detail.JobberRequestDetailModel
import com.jobloyal.jobber.model.update.UpdateResponseModel
import com.jobloyal.model.CheckUpdateRequest
import com.jobloyal.model.ResponseModel
import com.jobloyal.network.CommonApiService
import com.jobloyal.network.Http.HttpClient
import com.jobloyal.network.JobberApiService
import com.jobloyal.utility.Const
import com.jobloyal.utility.RxViewModel
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import io.reactivex.subjects.BehaviorSubject
import io.reactivex.subjects.PublishSubject

class JobberViewModel(val app: Application) : RxViewModel(app) {

    var lastRequest : BehaviorSubject<ResponseModel<JobberRequestDetailModel>> = BehaviorSubject.create()
    var pushedRequest : PublishSubject<RequestModel> = PublishSubject.create()
    var canceledRequest : PublishSubject<FCMCanceledRequest> = PublishSubject.create()
    var lastStatus : String? = null
    val update: BehaviorSubject<UpdateResponseModel> = BehaviorSubject.create()
    var state : String? = null;

    fun getLastRequestDetail () {
        subscribe(
            HttpClient.buildRx<JobberApiService>(context = getApplication())
                .getDetailOfLastLiveRequest().subscribeOn(
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

    fun sendFCMToken(token: String) {
        val id = Settings.Secure.getString(
            app.contentResolver,
            Settings.Secure.ANDROID_ID
        );
        subscribe(HttpClient.buildRx<JobberApiService>(context = getApplication())
            .addDevice(
                AddDeviceInfoModel(device_id = id, "android", "android-jobber", token)
            ).subscribeOn(Schedulers.io())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe({
                Const.setFCMSent(getApplication())
            }, {})
        )
    }

    fun checkVersion() {
        subscribe(
            HttpClient.buildRx<CommonApiService>(context = getApplication())
                .checkUpdate(CheckUpdateRequest("android", true)).subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    ifSuccess(it) {
                        it?.let {
                            if (it.version_code != null && it.version_code > BuildConfig.VERSION_CODE) {
                                if (it.force == true) {
                                    update.onNext(it)
                                } else if ((plusTime()) % (if (it.period ?: 1 == 0) 1 else it.period
                                        ?: 1) == 0
                                ) {
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

    fun sendNewRequestToObservable(data: String?) {
        if (data == null) return;
        try {
            val job = Gson().fromJson(data, RequestModel::class.java)
            pushedRequest.onNext(job)
        }
        catch (e: JsonSyntaxException) {

        }
    }

    fun canceledRequestToObservable (data : String?) {
        if (data == null) return;
        try {
            val req = Gson().fromJson(data, FCMCanceledRequest::class.java)
            canceledRequest.onNext(req)
        }
        catch (e: JsonSyntaxException) {

        }
    }


}