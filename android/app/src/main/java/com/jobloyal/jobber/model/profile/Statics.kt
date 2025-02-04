package com.jobloyal.jobber.model.profile

import android.os.Parcelable
import kotlinx.parcelize.Parcelize

@Parcelize
data class Statics(
    val card_number: String?,
    val createdAt: String?,
    val id: Int?,
    val jobber_id: String?,
    val notification_enabled: Boolean?,
    val pony_period: Int?,
    val sms_enabled: Boolean?,
    val updatedAt: String?
) : Parcelable