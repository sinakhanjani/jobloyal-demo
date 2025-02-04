package com.jobloyal.jobber.model.addservice

data class AddServiceToJobberRequestModel(
    val job_id: String?,
    val price: Float?,
    val service_id: String?,
    val unit_id: String?
)