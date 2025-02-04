package com.jobloyal.jobber.model.request

import android.os.Parcelable
import kotlinx.parcelize.Parcelize

@Parcelize
data class Service(
    val count: Int?,
    val id: Int?,
    val price: Double?,
    val request_id: String?,
    val title: String?,
    val unit: String?,
    @Transient var selected : Boolean = false,

    //it's property when a service has been accepted
    val total_price: Double?,
    val accepted: Boolean?,
) : Parcelable