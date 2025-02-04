package com.jobloyal.user.profile.edit

import android.app.Application
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.jobloyal.login.register.jobber.RegisterJobberViewModel
import com.jobloyal.network.Http.HttpClient
import com.jobloyal.network.JobberApiService
import com.jobloyal.network.UserApiService
import com.jobloyal.user.model.login.UserRegisterRequestModel
import com.jobloyal.utility.RxViewModel
import io.reactivex.Single
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers

class UserEditProfileViewModel(app : Application) : RxViewModel(app) {

    var firstName = ""
    var lastName = ""
    var email = ""
    var address = ""
    var gender : Boolean? = null
    var birthday : String? = null
    var waiting = MutableLiveData<Boolean>()

    fun save () {
        waiting.value = true
        subscribe(
            HttpClient.buildRx<UserApiService>(context = getApplication())
                .updateProfile(UserRegisterRequestModel(address,birthday,email,lastName,gender,firstName,null)).subscribeOn(
                    Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    waiting.value = false
                    ifSuccess(it) {
                        navigate.value = 1
                    }
                }, {
                    waiting.value = false
                })
        )
    }

    fun deleteAccount() = Single.create<Boolean> { single ->
        waiting.value = true
        subscribe(
            HttpClient.buildRx<UserApiService>(context = getApplication())
                .deleteAccount()
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    waiting.value = false
                    ifSuccess(it) {
                        single.onSuccess(true)
                    }
                }, {
                    waiting.value = false
                })
        )
    }

}