package com.jobloyal.jobber.model.job_page

data class JobberService(
    val id: String?,
    val price: Float?,
    val title: String?,
    val unit: String?,

    @Transient var loading : Boolean = false
)