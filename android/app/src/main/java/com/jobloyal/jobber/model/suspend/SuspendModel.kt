package com.jobloyal.jobber.model.suspend

data class SuspendModel(
    val createdAt: String?,
    val expired: String?,
    val finite: Boolean?,
    val id: Int?,
    val reason: String?,
    val system: Boolean?,
    val updatedAt: String?,
    val user_id: String?
)