package com.jobloyal.user.model.jobber

data class FindJobberRequestModel(
    val job_id: String?,
    val latitude: Double?,
    val longitude: Double?,
    val page: Int?,
    val service_id: String?
)