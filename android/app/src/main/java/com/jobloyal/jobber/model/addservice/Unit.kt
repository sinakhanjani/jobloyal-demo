package com.jobloyal.jobber.model.addservice

import android.os.Parcelable
import kotlinx.android.parcel.Parcelize

@Parcelize
data class Unit(
    val id: String?,
    val title: String?,
) : Parcelable