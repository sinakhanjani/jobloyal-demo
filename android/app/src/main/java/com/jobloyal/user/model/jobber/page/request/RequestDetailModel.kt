package com.jobloyal.user.model.jobber.page.request

data class RequestDetailModel(
    val arrival_time: String?,
    val id: String?,
    val job_id: String?,
    val remaining_time: Int?,
    val services: List<RequestedService>?,
    val status: String?,
    val time_base: Boolean?,
    val total_pay: Float?,
    val total_time_interval: Int?,
    val user_time_paying: Int?
)