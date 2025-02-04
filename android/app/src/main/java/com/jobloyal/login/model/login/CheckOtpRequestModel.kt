package com.jobloyal.login.model.login

data class CheckOtpRequestModel(
    val code: String?,
    val phoneNumber: String?
)