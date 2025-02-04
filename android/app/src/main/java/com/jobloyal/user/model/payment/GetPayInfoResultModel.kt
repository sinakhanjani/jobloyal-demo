package com.jobloyal.user.model.payment

import android.os.Parcelable
import kotlinx.parcelize.Parcelize

@Parcelize
data class GetPayInfoResultModel(
    val client_secret: String?,
    val id: String?,
    val customer: String?,
    val ephemeral_key: String?,
    val paid: Boolean?,
) : Parcelable