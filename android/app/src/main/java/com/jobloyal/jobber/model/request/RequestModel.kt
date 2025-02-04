package com.jobloyal.jobber.model.request

import android.os.Parcelable
import kotlinx.parcelize.Parcelize

@Parcelize
data class RequestModel(
    val address: String?,
    val distance: Double?,
    val id: String?,
    val job_title: String?,
    val price: String?,
    var remaining_time: Double?,
    val services: List<Service>?,
    val request_life_time: Int? = null,
) : Parcelable