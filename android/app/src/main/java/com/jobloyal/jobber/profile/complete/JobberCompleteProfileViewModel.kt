package com.jobloyal.jobber.profile.complete

import android.app.Application
import android.os.FileUtils
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.jobloyal.jobber.model.profile.JobberProfileModel
import com.jobloyal.jobber.model.profile.edit.CompleteProfileModel
import com.jobloyal.network.Http.HttpClient
import com.jobloyal.network.JobberApiService
import com.jobloyal.utility.RxViewModel
import com.jobloyal.utility.getExtension
import com.jobloyal.utility.getMimeType
import io.reactivex.Single
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import io.reactivex.subjects.BehaviorSubject
import okhttp3.MediaType
import okhttp3.MultipartBody
import okhttp3.RequestBody
import java.io.File
import java.util.*

class JobberCompleteProfileViewModel(app: Application) : RxViewModel(app) {

    val waiting = MutableLiveData<Boolean>()
    var aboutUs: String? = null
    var address: String? = null
    var birthday: String? = null
    var email: String? = null
    var gender: Boolean? = null
    var avatar : File? = null

    fun completeProfile() {
        waiting.value = true
        subscribe(
            HttpClient.buildRx<JobberApiService>(context = getApplication())
                .completeProfile(
                    CompleteProfileModel(
                        aboutUs,
                        address,
                        birthday,
                        email,
                        gender = gender
                    )
                ).subscribeOn(Schedulers.io())
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

    fun updateProfile() {
        waiting.value = true
        subscribe(
            HttpClient.buildRx<JobberApiService>(context = getApplication())
                .editProfile(CompleteProfileModel(aboutUs, address, null, email, gender = null))
                .subscribeOn(Schedulers.io())
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
            HttpClient.buildRx<JobberApiService>(context = getApplication())
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

    fun uploadAvatar() {
        waiting.value = true
        val builder = MultipartBody.Builder()
        builder.setType(MultipartBody.FORM)
        builder.addFormDataPart(
            "avatar",
            UUID.randomUUID().toString() + getExtension(avatar?.name),
            RequestBody.create(MediaType.parse(getMimeType(avatar!!)), avatar)
        )
        val requestBody: MultipartBody = builder.build()
        subscribe(
            HttpClient.buildRx<JobberApiService>(context = getApplication())
                .uploadAvatar(requestBody.parts())
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    navigate.value = 2
                    waiting.value = false
                }, {
                    waiting.value = false
                })
        )
    }
}