package com.jobloyal.jobber.model.message

import android.os.Parcelable
import kotlinx.parcelize.Parcelize

@Parcelize
data class Reply(
    val answer: String?,
    val createdAt: String?,
    val id: String?,
    val message_id: String?,
    val updatedAt: String?
) : Parcelable