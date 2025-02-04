package com.jobloyal.login.model.register

data class JobberRegisterRequestModel(
    val name: String?,
    val family: String?,
    val zip_code: String?,
    val identifier: String?,
    val region: String?,
)