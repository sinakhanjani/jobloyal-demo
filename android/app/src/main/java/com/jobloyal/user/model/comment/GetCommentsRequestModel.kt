package com.jobloyal.user.model.comment

data class GetCommentsRequestModel(
    val job_id: String?,
    val jobber_id: String?,
    val limit: Int?,
    val page: Int?
)