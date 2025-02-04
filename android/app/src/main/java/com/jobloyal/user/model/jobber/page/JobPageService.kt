package com.jobloyal.user.model.jobber.page

import android.os.Parcelable
import kotlinx.parcelize.Parcelize

@Parcelize
data class JobPageService(
    val commission: Int?,
    val id: String?,
    val price: Float?,
    val title: String?,
    val unit: String?,
    @Transient var selected : Boolean = false,
    @Transient var count : Int? = null
) : Parcelable