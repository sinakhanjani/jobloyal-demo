package com.jobloyal.jobber.profile.notification

import android.app.Application
import android.content.Context
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.jobloyal.jobber.model.profile.edit.NotificationEditModel
import com.jobloyal.jobber.model.profile.edit.PaymentEditModel
import com.jobloyal.network.Http.HttpClient
import com.jobloyal.network.JobberApiService
import com.jobloyal.utility.LocalAlarmManager
import com.jobloyal.utility.RxViewModel
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers

class JobberSettingNotificationViewModel(val app: Application) : RxViewModel(app) {


    var waiting = MutableLiveData<Boolean>()

    fun save (sms: Boolean, notification : Boolean) {
        waiting.value = true
        subscribe(
            HttpClient.buildRx<JobberApiService>(context = getApplication())
                .editNotification(NotificationEditModel(notification, sms)).subscribeOn(
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

    fun saveAlarmState (state : Boolean) {
        val stateInt = if (state) 1 else 2
        val state = app.getSharedPreferences("settings", Context.MODE_PRIVATE)?.getInt("alarmState",0) ?: 0
        if (state != stateInt) {
            if (state == 1)
                LocalAlarmManager.startAlarmBroadcastReceiver(app)
            else
                LocalAlarmManager.cancelAlarm(app)
            app.getSharedPreferences("settings", Context.MODE_PRIVATE)?.edit()?.putInt("alarmState",stateInt)?.apply()
        }
    }

    fun isAlarmEnabled (): Boolean {
        return (app.getSharedPreferences("settings", Context.MODE_PRIVATE)?.getInt("alarmState",0) ?: 0) == 1
    }


}