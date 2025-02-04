package com.jobloyal.jobber.model.message

import android.os.Parcelable
import kotlinx.parcelize.Parcelize

@Parcelize
data class MessageModel(
    val createdAt: String?,
    val description: String?,
    val id: String?,
    val reply: Reply?,
    val subject: String?,
    val updatedAt: String?,
    val user_id: String?
) : Parcelable