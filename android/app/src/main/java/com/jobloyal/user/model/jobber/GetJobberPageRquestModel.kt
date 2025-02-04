package com.jobloyal.user.model.jobber

data class GetJobberPageRquestModel(
    val job_id: String?,
    val jobber_id: String?,
    val latitude: String?,
    val longitude: String?
)