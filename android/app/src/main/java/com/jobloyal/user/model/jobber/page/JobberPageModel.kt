package com.jobloyal.user.model.jobber.page

import com.jobloyal.user.model.jobber.page.request.RequestDetailModel

data class JobberPageModel(
    val id : String? = null,
    val about_me: String?,
    val avatar: String?,
    val comments: List<Comment>?,
    val distance: Double?,
    val identifier: String?,
    val rate: String?,
    val services: List<JobPageService>?,
    val status: String?,
    val total_comments: Int?,
    val work_count: Int?,
    val phone_number: String?,
    val name: String?,
    val request: RequestDetailModel?
)