package com.jobloyal.jobber.category.jobs

import android.app.Application
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.jobloyal.jobber.model.category.CategoryModel
import com.jobloyal.jobber.model.category.JobsByCategoryIDRequestModel
import com.jobloyal.jobber.model.category.jobs.JobsInCategoryModel
import com.jobloyal.network.Http.HttpClient
import com.jobloyal.network.JobberApiService
import com.jobloyal.utility.RxViewModel
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import io.reactivex.subjects.BehaviorSubject

class JobsCategoryViewModel(app : Application) : RxViewModel(app) {

    var jobs : BehaviorSubject<List<CategoryModel>> = BehaviorSubject.create()
    var waiting = MutableLiveData<Boolean>()
    var categoryId : String? = null
    fun getCategories () {
        waiting.value = true
        subscribe(
            HttpClient.buildRx<JobberApiService>(context = getApplication())
                .getJobsByCategoryId(JobsByCategoryIDRequestModel(categoryId)).subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    waiting.value = false
                    ifSuccess(it) { jobs ->
                        jobs?.items?.let {
                            this.jobs.onNext(it)
                        }
                    }
                }, {
                    waiting.value = false
                })
        )
    }
}