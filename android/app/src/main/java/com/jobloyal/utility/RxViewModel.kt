package com.jobloyal.utility

import android.app.Application
import android.util.Log
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.MutableLiveData
import com.jobloyal.model.ResponseInterface
import com.jobloyal.model.ResponseModel
import com.jobloyal.model.ResponseModelParent
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.disposables.Disposable

data class ErrorStructure (val error: String, val code : Int)
open class RxViewModel(application: Application) : AndroidViewModel(application) {
    private val subscriptions = CompositeDisposable()
    val navigate = MutableLiveData<Int>()
    val error = MutableLiveData<ErrorStructure>()

    fun subscribe(disposable: Disposable): Disposable {
        subscriptions.add(disposable)
        return disposable
    }

    override fun onCleared() {
        super.onCleared()
        subscriptions.dispose() //delete and not allow to add new disposable
    }

    fun <T> ifSuccess (res : ResponseModelParent<T>, code : ((T?) -> Unit)) {
        if (res.success) {
            code(res.data)
        }
        else {
//            when (res.code) {
//
//            }
            error.value = ErrorStructure(res.message ?: "",res.code ?: 0)
        }
    }
    fun <T> ifSuccessOrNot (res : ResponseModelParent<T>, code : ((T?) -> Unit), err: ( (ResponseModelParent<T>) -> Boolean)? = null) {
        if (res.success) {
            code(res.data)
        }
        else {
            if (err?.invoke(res) != false) {
//                when (res.code) {
                    error.value = ErrorStructure(res.message ?: "",res.code ?: 0)
//                }
            }
        }
    }

}