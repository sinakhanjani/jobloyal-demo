package com.jobloyal.jobber.profile.authentication

import android.app.Application
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.jobloyal.jobber.model.profile.edit.CompleteProfileModel
import com.jobloyal.network.Http.HttpClient
import com.jobloyal.network.JobberApiService
import com.jobloyal.utility.RxViewModel
import com.jobloyal.utility.getExtension
import com.jobloyal.utility.getMimeType
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import okhttp3.MediaType
import okhttp3.MultipartBody
import okhttp3.RequestBody
import java.io.File
import java.util.*

class AuthentictionViewModel(app: Application) : RxViewModel(app) {

    var document : File? = null
    val waiting = MutableLiveData<Boolean>()

    fun uploadDocument () {
        waiting.value = true
        val builder = MultipartBody.Builder()
        builder.setType(MultipartBody.FORM)
        builder.addFormDataPart(
            "doc",
            UUID.randomUUID().toString() + getExtension(document?.name),
            RequestBody.create(MediaType.parse(getMimeType(document!!)), document)
        )
        val requestBody: MultipartBody = builder.build()
        subscribe(
            HttpClient.buildRx<JobberApiService>(context = getApplication())
                .uploadDocument(requestBody.parts())
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    navigate.value = 1
                    waiting.value = false
                }, {
                    waiting.value = false
                })
        )
    }
}