package com.jobloyal.network

import com.jobloyal.jobber.model.category.CategoryModel
import com.jobloyal.jobber.model.category.JobsByCategoryIDRequestModel
import com.jobloyal.jobber.model.deivce_info.AddDeviceInfoModel
import com.jobloyal.jobber.model.report.PaginationModel
import com.jobloyal.login.model.login.GetTokenResponseModel
import com.jobloyal.login.model.register.JobberRegisterRequestModel
import com.jobloyal.model.ResponseArrayModel
import com.jobloyal.model.ResponseModel
import com.jobloyal.model.SuccessBaseResponseModel
import com.jobloyal.user.model.comment.GetCommentsRequestModel
import com.jobloyal.user.model.comment.SubmitCommentRequestModel
import com.jobloyal.user.model.jobber.FindJobberRequestModel
import com.jobloyal.user.model.jobber.GetJobberPageRquestModel
import com.jobloyal.user.model.jobber.NearJobberModel
import com.jobloyal.user.model.jobber.page.Comment
import com.jobloyal.user.model.jobber.page.JobberPageModel
import com.jobloyal.user.model.login.UserRegisterRequestModel
import com.jobloyal.user.model.payment.GetPayInfoResultModel
import com.jobloyal.user.model.payment.UseWalletMode
import com.jobloyal.user.model.profile.UserProfileModel
import com.jobloyal.user.model.profile.UserWalletModel
import com.jobloyal.user.model.profile.reserved.ReservedServicesModel
import com.jobloyal.user.model.request.CreateNewRequestModel
import com.jobloyal.user.model.request.last.LastRequestStatusResponseModel
import com.jobloyal.user.model.service.SearchServiceModel
import com.jobloyal.user.model.service.SearchServiceRequestModel
import io.reactivex.Single
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.Header
import retrofit2.http.POST

interface UserApiService {
    @POST("user/register/register")
    fun register(@Body body : UserRegisterRequestModel, @Header("Authorization") auth : String): Single<ResponseModel<GetTokenResponseModel>>

    @GET("user/categories")
    fun getCategories(): Single<ResponseArrayModel<CategoryModel>>

    @POST("user/service/search")
    fun searchService(@Body body : SearchServiceRequestModel): Single<ResponseArrayModel<SearchServiceModel>>

    @POST("user/jobs")
    fun getAllJobsInCategory(@Body body : JobsByCategoryIDRequestModel): Single<ResponseArrayModel<CategoryModel>>

    @POST("user/jobber/find_by_job")
    fun findByJob(@Body body : FindJobberRequestModel): Single<ResponseArrayModel<NearJobberModel>>

    @POST("user/jobber/find_by_service")
    fun findJobByService(@Body body : FindJobberRequestModel): Single<ResponseArrayModel<NearJobberModel>>

    @POST("user/jobber/page")
    fun getJobberPage(@Body body : GetJobberPageRquestModel): Single<ResponseModel<JobberPageModel>>

    @GET("user/request/last_request_detail")
    fun getLastRequestDetail(): Single<ResponseModel<JobberPageModel>>

    @GET("user/request/status_last_request")
    fun lastRequestStatus(): Single<ResponseModel<LastRequestStatusResponseModel>>

    @GET("user/wallet")
    fun getWalletCredit(): Single<ResponseModel<UserWalletModel>>

    @POST("user/request/add")
    fun createNewRequest(@Body body : CreateNewRequestModel): Single<SuccessBaseResponseModel>

    @POST("user/request/cancel")
    fun cancelJob(): Single<SuccessBaseResponseModel>

    @POST("user/payment/pay")
    fun payJob(@Body body : UseWalletMode): Single<ResponseModel<GetPayInfoResultModel>>

    @POST("user/payment/check-pay")
    fun checkPay(): Single<ResponseModel<SuccessBaseResponseModel>>

    @POST("user/payment/verify-pay")
    fun verifyJob(): Single<SuccessBaseResponseModel>

    @POST("user/comment/submit")
    fun submitComment(@Body body : SubmitCommentRequestModel): Single<SuccessBaseResponseModel>

    @GET("user/profile")
    fun getProfile(): Single<ResponseModel<UserProfileModel>>

    @POST("user/device/add")
    fun addDevice(@Body body : AddDeviceInfoModel): Single<SuccessBaseResponseModel>

    @POST("user/device/logout")
    fun deleteDevice(@Body body : AddDeviceInfoModel): Single<SuccessBaseResponseModel>

    @POST("user/service/reserved_services")
    fun getReservedServices(@Body body : PaginationModel): Single<ResponseArrayModel<ReservedServicesModel>>

    @POST("user/service/canceled_services")
    fun getCanceledServices(@Body body : PaginationModel): Single<ResponseArrayModel<ReservedServicesModel>>

    @POST("user/profile/edit")
    fun updateProfile(@Body body : UserRegisterRequestModel): Single<SuccessBaseResponseModel>

    @POST("user/comments")
    fun getCommentsOfJob(@Body body : GetCommentsRequestModel): Single<ResponseArrayModel<Comment>>

    @POST("user/delete-account")
    fun deleteAccount(): Single<SuccessBaseResponseModel>
}