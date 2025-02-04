package com.jobloyal.jobber.main.requests

import android.app.Application
import android.content.Context
import android.content.ContextWrapper
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Environment
import androidx.lifecycle.MutableLiveData
import com.jobloyal.jobber.model.request.RequestIDModel
import com.jobloyal.jobber.model.request.RequestModel
import com.jobloyal.jobber.model.status.GetLocationModel
import com.jobloyal.network.Http.HttpClient
import com.jobloyal.network.JobberApiService
import com.jobloyal.utility.RxViewModel
import io.reactivex.Single
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import io.reactivex.subjects.BehaviorSubject
import io.reactivex.subjects.ReplaySubject
import java.io.*


class JobberRequestsViewModel(app: Application) : RxViewModel(app) {

    companion object {
        var backgroundImageMap : Bitmap? = null
        var currentJobberLocation : GetLocationModel? = null
        fun loadImage(app: Context, forceNew: Boolean) : Boolean {
            try {
                val path = ContextWrapper(app).filesDir
                var mapPic: File? = null
                if (!forceNew) {
                    for (f in path.listFiles() ?: arrayOf()) {
                        if (f.isFile && f.name.startsWith("jobloyal-map-background") && f.name.endsWith(
                                ".jpg"
                            )) {
                            mapPic = f
                            break
                        }
                    }
                }
                else if (currentJobberLocation?.id != null) {
                    val tmp = File(path, "jobloyal-map-background-${currentJobberLocation?.id}.jpg")
                    if (tmp.exists())
                        mapPic = tmp
                }
                if (mapPic != null) {
                    val b = BitmapFactory.decodeStream(FileInputStream(mapPic))
                    backgroundImageMap = b
                    return true
                }
                return false
            } catch (e: FileNotFoundException) {
                e.printStackTrace()
                return false
            }
        }
    }
    fun saveMap () {
        if (backgroundImageMap != null) {
            val path = ContextWrapper(getApplication()).filesDir
            for (child in path.listFiles() ?: arrayOf()) {
                child.delete()
            }
            var fOut: OutputStream? = null
            val counter = currentJobberLocation?.id ?: 0
            val file = File(
                path,
                "jobloyal-map-background-$counter.jpg"
            )
            fOut = FileOutputStream(file)
            backgroundImageMap?.compress(
                Bitmap.CompressFormat.JPEG,
                85,
                fOut
            )
            fOut.flush()
            fOut.close()
        }
    }

    var waiting = MutableLiveData<Boolean>()
    val requests : ReplaySubject<List<RequestModel>> = ReplaySubject.create()
    var requestLifeTime = 0
    var loaded = false
    var referesh = true

    fun getAllLiveRequests () {
        waiting.value = true
        subscribe(
            HttpClient.buildRx<JobberApiService>(context = getApplication())
                .getAllRequests().subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    waiting.value = false
                    ifSuccess(it) { jobs ->
                        jobs?.items?.let {
                            requestLifeTime = jobs.requestLifeTime
                            loaded = true
                            requests.onNext(it)
                        }
                    }
                }, {
                    waiting.value = false
                })
        )
    }

    fun rejectRequest(id: String) = Single.create<Boolean> { single ->
        subscribe(
            HttpClient.buildRx<JobberApiService>(context = getApplication())
                .rejectRequest(RequestIDModel(id)).subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    ifSuccess(it) {
                        single.onSuccess(true)
                    }
                }, {
                })
        )
    }
}