package com.jobloyal.jobber.model

class MyJobModel(
    val enabled: Boolean? = null,
    val job_id: String? = null,
    val service_conut: String? = null,
    var status: String? = null,
    var status_created_time: String? = null,
    val title: String? = null
) {
    fun updateModel (status: String? = null, status_created_time: String? = null) {
        this.status = status
        this.status_created_time = status_created_time
    }
}