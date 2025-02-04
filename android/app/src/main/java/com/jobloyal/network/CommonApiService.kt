package com.jobloyal.network

import com.jobloyal.jobber.model.message.MessageModel
import com.jobloyal.jobber.model.message.SendMessageRequestModel
import com.jobloyal.jobber.model.suspend.SuspendModel
import com.jobloyal.jobber.model.update.UpdateResponseModel
import com.jobloyal.login.model.SetRegionRequestModel
import com.jobloyal.login.model.login.CheckOtpRequestModel
import com.jobloyal.login.model.login.GetTokenResponseModel
import com.jobloyal.login.model.login.LoginRequestModel
import com.jobloyal.model.*
import io.reactivex.Single
import okhttp3.MultipartBody
import retrofit2.http.*

interface CommonApiService {


    @POST("common/otp/send")
    fun sendOTP(@Body body : LoginRequestModel): Single<SuccessBaseResponseModel>

    @POST("common/otp/check")
    fun checkOtp(@Body body : CheckOtpRequestModel): Single<ResponseModel<GetTokenResponseModel>>

    @POST("common/version")
    fun checkUpdate(@Body body : CheckUpdateRequest): Single<ResponseModel<UpdateResponseModel>>

    @POST("{url}/register/get_token")
    fun getToken(@Path(value = "url", encoded = false) type : String, @Header("Authorization") auth: String,@Body body : ChangeRegionRequestModel): Single<ResponseModel<GetTokenResponseModel>>

    @POST("{url}/profile/edit_region")
    fun changeRegion(@Path(value = "url", encoded = false) type : String, @Body body : ChangeRegionRequestModel): Single<ResponseModel<GetTokenResponseModel>>

    @GET("{url}/messages")
    fun getMessages(@Path(value = "url", encoded = false) type : String): Single<ResponseArrayModel<MessageModel>>

    @POST("{url}/message/send")
    fun postMessage(@Path(value = "url", encoded = false) type : String, @Body body: SendMessageRequestModel): Single<SuccessBaseResponseModel>

    @GET("{url}/suspend/detail")
    fun getDetailOfSuspend(@Path(value = "url", encoded = false) type : String): Single<ResponseModel<SuspendModel>>

    @POST("{url}/profile/edit_region")
    fun setRegion(@Path(value = "url", encoded = false) type : String,@Body body : SetRegionRequestModel): Single<ResponseModel<GetTokenResponseModel>>

//    @Multipart
//    @POST("receipt/upload")
//    fun uploadReceipt(@Part file : List<MultipartBody.Part>): Single<SuccessBaseResponseModel>

}