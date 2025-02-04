package com.jobloyal.jobber.model.category

import android.os.Parcelable
import kotlinx.android.parcel.Parcelize

@Parcelize
data class CategoryModel(
    val createdAt: String?,
    val id: String?,
    val title: String?,
    val updatedAt: String?,
    val children : Array<CategoryModel>?
) : Parcelable