package com.jobloyal.jobber.addservice.newservice

import android.app.Application
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.jobloyal.jobber.model.addservice.*
import com.jobloyal.jobber.model.addservice.Unit
import com.jobloyal.jobber.model.category.CategoryModel
import com.jobloyal.network.Http.HttpClient
import com.jobloyal.network.JobberApiService
import com.jobloyal.utility.RxViewModel
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import io.reactivex.subjects.BehaviorSubject

class NewServiceViewModel(app: Application) : RxViewModel(app) {

    var price : Float = 0f
    var isNewJob : Boolean = false
    var isNewJobReal : Boolean = false
    var service : SearchServiceModel? = null
    var jobId : String? = null
    var units : BehaviorSubject<List<Unit>> = BehaviorSubject.create()
    var selectedUnit : Unit? = null
    var waiting = MutableLiveData<Boolean>()
    enum class UnitType {TIME_BASE, NUMERIC}
    var unitType : UnitType? = null

    fun getAllUnits () {
        subscribe(
            HttpClient.buildRx<JobberApiService>(context = getApplication())
                .getAllUnits().subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    ifSuccess(it) { jobs ->
                        jobs?.items?.let {
                            units.onNext(it)
                        }
                    }
                }, {
                })
        )
    }

    fun save () {
        waiting.value = true
        when {
            selectedUnit?.id == null && unitType == UnitType.NUMERIC -> {
                subscribe(saveUnit().subscribe({
                    waiting.value = false
                    ifSuccess(it) {
                        selectedUnit = it
                        save()
                    }
                },{
                    waiting.value = false
                }))
            }
            service?.id == null -> {
                saveService().subscribe({
                    waiting.value = false

                    ifSuccess(it) {
                        this.service = it
                        save()
                    }
                }, {
                    waiting.value = false
                })
            }
            isNewJob -> {
                addJobToJobber().subscribe({
                    waiting.value = false
                    ifSuccess(it) {
                        isNewJob = false
                        save()
                    }
                }, {
                    waiting.value = false
                })
            }
            else -> {
                addServiceToJobber()
            }
        }
    }

    private fun saveUnit () =
            HttpClient.buildRx<JobberApiService>(context = getApplication())
                .saveNewUnit(AddNewUnitRequestModel(title = selectedUnit?.title)).subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())


    private fun saveService () =
            HttpClient.buildRx<JobberApiService>(context = getApplication())
                .saveNewService(CreateNewServiceRequestModel(jobId, service?.title, selectedUnit?.id)).subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())

    private fun addJobToJobber () =
            HttpClient.buildRx<JobberApiService>(context = getApplication())
                .addJobToJobber(JobberSearchServiceRequest(job_id = jobId)).subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())

    private fun addServiceToJobber () {
        waiting.value = true
        subscribe(
            HttpClient.buildRx<JobberApiService>(context = getApplication())
                .addServiceToJobOfJobber(AddServiceToJobberRequestModel(jobId, price = price, service?.id,selectedUnit?.id)).subscribeOn(Schedulers.io())
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
}