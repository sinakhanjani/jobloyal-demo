package com.jobloyal.jobber.category

import android.app.Application
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.jobloyal.jobber.model.category.CategoryModel
import com.jobloyal.network.Http.HttpClient
import com.jobloyal.network.JobberApiService
import com.jobloyal.utility.RxViewModel
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import io.reactivex.subjects.BehaviorSubject

class CategoryViewModel(app : Application) : RxViewModel(app) {

    var categories : BehaviorSubject<List<CategoryModel>> = BehaviorSubject.create()
    var waiting = MutableLiveData<Boolean>()

    fun getCategories () {
        waiting.value = true
        subscribe(
            HttpClient.buildRx<JobberApiService>(context = getApplication())
                .getCategories().subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    waiting.value = false
                    ifSuccess(it) { jobs ->
                        jobs?.items?.let {
                            categories.onNext(it)
                        }
                    }
                }, {
                    waiting.value = false
                })
        )
    }
}