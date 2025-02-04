package com.jobloyal.jobber.model.addservice

import android.os.Parcelable
import kotlinx.android.parcel.Parcelize

@Parcelize
data class SearchServiceModel(
    val id: String? = null,
    val title: String? = null,
    val unit: Unit? = null,
    val default_unit_id: String? = null
    ) : Parcelable