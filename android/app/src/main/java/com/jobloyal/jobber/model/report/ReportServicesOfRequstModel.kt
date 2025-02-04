package com.jobloyal.jobber.model.report

import com.jobloyal.jobber.model.request.Service

data class ReportServicesOfRequstModel(
    val address: String?,
    val created_at: String?,
    val id: String?,
    val services: List<Service>?,
    val status: String?
)