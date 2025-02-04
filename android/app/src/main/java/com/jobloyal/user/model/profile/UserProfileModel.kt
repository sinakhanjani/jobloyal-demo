package com.jobloyal.user.model.profile

import android.os.Parcelable
import kotlinx.parcelize.Parcelize

@Parcelize
data class UserProfileModel(
    val address: String?,
    val birthday: String?,
    val createdAt: String?,
    val credit: Double?,
    val email: String?,
    val family: String?,
    val gender: Boolean?,
    val id: String?,
    val name: String?,
    val phone_number: String?,
    val region: String?,
    val updatedAt: String?
) : Parcelable