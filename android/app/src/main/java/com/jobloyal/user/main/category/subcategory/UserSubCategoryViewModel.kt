package com.jobloyal.user.main.category.subcategory

import android.app.Application
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.jobloyal.jobber.model.category.CategoryModel
import com.jobloyal.jobber.model.category.JobsByCategoryIDRequestModel
import com.jobloyal.network.Http.HttpClient
import com.jobloyal.network.UserApiService
import com.jobloyal.user.model.service.SearchServiceModel
import com.jobloyal.utility.RxViewModel
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.Disposable
import io.reactivex.schedulers.Schedulers
import io.reactivex.subjects.BehaviorSubject

class UserSubCategoryViewModel(app: Application) : RxViewModel(app) {

    var categoryId : String? = null
    var jobs : BehaviorSubject<List<CategoryModel>> = BehaviorSubject.create()
    var waiting = MutableLiveData<Boolean>()

    fun getJobs () {
        waiting.value = true
        subscribe(
            HttpClient.buildRx<UserApiService>(context = getApplication())
                .getAllJobsInCategory(JobsByCategoryIDRequestModel(categoryId)).subscribeOn(Schedulers.io())
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