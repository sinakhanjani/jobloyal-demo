package com.jobloyal.jobber.model.job_page

data class JobPageModel(
    val rate: String?,
    val request_count: Int?,
    val services: List<JobberService>?,
    val total_comments: Int?,
    val total_income: String?,
    val work_count: Int?
)