package com.jobloyal.jobber.model.request.detail

import com.jobloyal.jobber.model.request.Service

data class JobberRequestDetailModel(
    val address: String?,
    val arrival_time: String?,
    val distance: Double?,
    val id: String?,
    val job_id: String?,
    val latitude: Double?,
    val longitude: Double?,
    val remaining_time_to_pay: Int?,
    val total_time_interval: Int?,
    val services: List<Service>?,
    val status: String?,
    val time_base: Boolean?,
    val total: String?,
    val updated_at: String?,
    val user: User?,
    val user_time_paying: Int?
)