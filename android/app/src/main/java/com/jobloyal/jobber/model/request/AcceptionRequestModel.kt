package com.jobloyal.jobber.model.request

data class AcceptionRequestModel(
    val accepted_services: List<Int>?,
    val arrival_time: Int?,
    val request_id: String?
)