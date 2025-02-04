package com.jobloyal.user.main.category

import android.app.Application
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.jobloyal.jobber.model.category.CategoryModel
import com.jobloyal.network.Http.HttpClient
import com.jobloyal.network.JobberApiService
import com.jobloyal.network.UserApiService
import com.jobloyal.user.model.service.SearchServiceModel
import com.jobloyal.user.model.service.SearchServiceRequestModel
import com.jobloyal.utility.RxViewModel
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.Disposable
import io.reactivex.schedulers.Schedulers
import io.reactivex.subjects.BehaviorSubject

class UserCategoryViewModel(app: Application) : RxViewModel(app) {

    var categories : BehaviorSubject<List<CategoryModel>> = BehaviorSubject.create()
    var searchedServices : BehaviorSubject<List<SearchServiceModel>> = BehaviorSubject.create()
    var waiting = MutableLiveData<Boolean>()
    var disposable : Disposable? = null

    fun getCategories () {
        waiting.value = true
        subscribe(
            HttpClient.buildRx<UserApiService>(context = getApplication())
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

    fun searchService (search : String) {
        waiting.value = true
        disposable =
            HttpClient.buildRx<UserApiService>(context = getApplication())
                .searchService(SearchServiceRequestModel(search)).subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    waiting.value = false
                    ifSuccess(it) { jobs ->
                        jobs?.items?.let {
                            searchedServices.onNext(it)
                        }
                    }
                }, {
                    waiting.value = false
                })
    }
}