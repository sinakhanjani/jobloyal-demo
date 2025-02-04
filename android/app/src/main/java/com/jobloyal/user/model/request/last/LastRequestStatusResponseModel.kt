package com.jobloyal.user.model.request.last

data class LastRequestStatusResponseModel(
    val latitude: Double?,
    val longitude: Double?,
    val created_at: String?,
    val job_title: String?,
    val jobber: JobberInfo?,
    val remaining_time: Int?,
    val request_id: String?,
    val request_life_time: Int?,
    val service_count: String?,
    val status: String?,
    val tag: String?,
    val total_pay: Double?,
    val user_time_paying: Int?
)