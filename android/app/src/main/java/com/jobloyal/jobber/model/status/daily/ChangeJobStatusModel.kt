package com.jobloyal.jobber.model.status.daily

data class ChangeJobStatusModel(
    val createdAt: String?,
    val id: Int?,
    val job_id: String?,
    val jobber_id: String?,
    val status: String?
)