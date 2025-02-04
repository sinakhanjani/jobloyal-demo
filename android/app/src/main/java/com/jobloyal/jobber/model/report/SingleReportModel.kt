package com.jobloyal.jobber.model.report

import android.os.Parcelable
import kotlinx.parcelize.Parcelize

@Parcelize
data class SingleReportModel(
    val address: String? = null,
    val created_at: String? = null,
    val id: String? = null,
    val job_title: String? = null,
    val status: String? = null,
    val tag: String? = null
) : Parcelable