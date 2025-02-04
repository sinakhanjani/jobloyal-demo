package com.jobloyal.network

import com.jobloyal.jobber.model.MyJobModel
import com.jobloyal.jobber.model.addservice.*
import com.jobloyal.jobber.model.addservice.Unit
import com.jobloyal.jobber.model.category.CategoryModel
import com.jobloyal.jobber.model.category.JobsByCategoryIDRequestModel
import com.jobloyal.jobber.model.category.jobs.JobsInCategoryModel
import com.jobloyal.jobber.model.deivce_info.AddDeviceInfoModel
import com.jobloyal.jobber.model.job_page.DeleteServiceFromJob
import com.jobloyal.jobber.model.job_page.JobPageModel
import com.jobloyal.jobber.model.profile.JobberProfileModel
import com.jobloyal.jobber.model.profile.edit.CompleteProfileModel
import com.jobloyal.jobber.model.profile.edit.NotificationEditModel
import com.jobloyal.jobber.model.profile.edit.PaymentEditModel
import com.jobloyal.jobber.model.report.PaginationModel
import com.jobloyal.jobber.model.report.ReportServicesOfRequstModel
import com.jobloyal.jobber.model.report.SingleReportModel
import com.jobloyal.jobber.model.request.AcceptionRequestModel
import com.jobloyal.jobber.model.request.RequestIDModel
import com.jobloyal.jobber.model.request.RequestModel
import com.jobloyal.jobber.model.request.UserTimePaingResponseModel
import com.jobloyal.jobber.model.request.detail.JobberRequestDetailModel
import com.jobloyal.jobber.model.request.estimated.GetLocationRequestModel
import com.jobloyal.jobber.model.status.GetLocationModel
import com.jobloyal.jobber.model.status.UpdateLocationRequestModel
import com.jobloyal.jobber.model.status.daily.ChangeJobStatusModel
import com.jobloyal.jobber.model.status.daily.ChangeStatusJobOfJobberRequestModel
import com.jobloyal.jobber.model.turnover.TurnoverModel
import com.jobloyal.login.model.SetRegionRequestModel
import com.jobloyal.login.model.login.GetTokenResponseModel
import com.jobloyal.login.model.login.LoginRequestModel
import com.jobloyal.login.model.register.CheckAvailableIdentifierRequestModel
import com.jobloyal.login.model.register.JobberRegisterRequestModel
import com.jobloyal.model.ResponseArrayModel
import com.jobloyal.model.ResponseModel
import com.jobloyal.model.SuccessBaseResponseModel
import com.jobloyal.model.VainResponse
import com.jobloyal.user.model.comment.GetCommentsRequestModel
import com.jobloyal.user.model.jobber.page.Comment
import io.reactivex.Single
import okhttp3.MultipartBody
import retrofit2.http.*

interface JobberApiService {

    @POST("jobber/register/register")
    fun register(@Body body : JobberRegisterRequestModel, @Header("Authorization") auth : String): Single<ResponseModel<GetTokenResponseModel>>

    @POST("jobber/register/check_available_id")
    fun checkAvailableId(@Body body : CheckAvailableIdentifierRequestModel): Single<SuccessBaseResponseModel>

    @GET("jobber/job/myjobs")
    fun getMyJobs(): Single<ResponseArrayModel<MyJobModel>>

    @POST("jobber/status/location/add")
    fun updateLocation(@Body body : UpdateLocationRequestModel): Single<ResponseModel<GetLocationModel>>

    @GET("jobber/status/location/get")
    fun getLastLocation(): Single<ResponseModel<GetLocationModel>>

    @GET("jobber/categories")
    fun getCategories(): Single<ResponseArrayModel<CategoryModel>>

    @POST("jobber/job/get")
    fun getJobsByCategoryId(@Body body : JobsByCategoryIDRequestModel): Single<ResponseArrayModel<CategoryModel>> //model of jobs in category like a category cause we use same model

    @POST("jobber/service/search")
    fun searchService(@Body body : JobberSearchServiceRequest): Single<ResponseArrayModel<SearchServiceModel>>

    @POST("jobber/service/get")
    fun getAllServiceOnJob(@Body body : JobberSearchServiceRequest): Single<ResponseArrayModel<SearchServiceModel>>

    @GET("jobber/unit/all")
    fun getAllUnits(): Single<ResponseArrayModel<Unit>>

    @POST("jobber/unit/add")
    fun saveNewUnit(@Body body : AddNewUnitRequestModel): Single<ResponseModel<Unit>>

    @POST("jobber/service/create")
    fun saveNewService(@Body body : CreateNewServiceRequestModel): Single<ResponseModel<SearchServiceModel>>

    @POST("jobber/job/add")
    fun addJobToJobber(@Body body : JobberSearchServiceRequest): Single<ResponseModel<VainResponse>>

    @POST("jobber/service/add")
    fun addServiceToJobOfJobber(@Body body : AddServiceToJobberRequestModel): Single<SuccessBaseResponseModel>

    @POST("jobber/job/page")
    fun getJobPage(@Body body : JobberSearchServiceRequest): Single<ResponseModel<JobPageModel>>

    @POST("jobber/service/delete")
    fun deleteServiceFromJob(@Body body : DeleteServiceFromJob): Single<SuccessBaseResponseModel>

    @POST("jobber/status/add")
    fun changeStatusJobOfJobber(@Body body : ChangeStatusJobOfJobberRequestModel): Single<ResponseModel<ChangeJobStatusModel>>

    @GET("jobber/request/myrequest")
    fun getAllRequests(): Single<ResponseArrayModel<RequestModel>>

    @POST("jobber/request/reject")
    fun rejectRequest(@Body body : RequestIDModel): Single<SuccessBaseResponseModel>

    @GET("jobber/request/location/{id}")
    fun getLocation(@Path(value = "id", encoded = false) id : String?): Single<ResponseModel<GetLocationRequestModel>>

    @GET("jobber/request/status_last_request")
    fun getDetailOfLastLiveRequest(): Single<ResponseModel<JobberRequestDetailModel>>

    @POST("jobber/request/accept")
    fun acceptRequest(@Body body : AcceptionRequestModel): Single<ResponseModel<UserTimePaingResponseModel>>

    @POST("jobber/request/arrive")
    fun arriveJob(): Single<SuccessBaseResponseModel>

    @POST("jobber/request/start")
    fun startJob(): Single<SuccessBaseResponseModel>

    @POST("jobber/request/finish")
    fun finishJob(): Single<SuccessBaseResponseModel>

    @POST("jobber/request/cancel")
    fun cancelJob(): Single<SuccessBaseResponseModel>

    @POST("jobber/report")
    fun getReports(@Body body : PaginationModel): Single<ResponseArrayModel<SingleReportModel>>

    @GET("jobber/report/{id}")
    fun getReport(@Path(value = "id", encoded = false) id : String?): Single<ResponseModel<ReportServicesOfRequstModel>>

    @GET("jobber/profile")
    fun getProfile(): Single<ResponseModel<JobberProfileModel>>

    @GET("jobber/turnover")
    fun getTurnover(): Single<ResponseArrayModel<TurnoverModel>>

    @POST("jobber/device/add")
    fun addDevice(@Body body : AddDeviceInfoModel): Single<SuccessBaseResponseModel>

    @POST("jobber/device/logout")
    fun deleteDevice(@Body body : AddDeviceInfoModel): Single<SuccessBaseResponseModel>

    @POST("jobber/profile/edit_payment")
    fun editPayment(@Body body : PaymentEditModel): Single<SuccessBaseResponseModel>

    @POST("jobber/profile/edit_notification")
    fun editNotification(@Body body : NotificationEditModel): Single<SuccessBaseResponseModel>

    @POST("jobber/profile/update")
    fun editProfile(@Body body : CompleteProfileModel): Single<SuccessBaseResponseModel>

    @POST("jobber/delete-account")
    fun deleteAccount(): Single<SuccessBaseResponseModel>

    @POST("jobber/register/complete_profile")
    fun completeProfile(@Body body : CompleteProfileModel): Single<SuccessBaseResponseModel>

    @Multipart
    @POST("jobber/register/upload_avatar")
    fun uploadAvatar(@Part file : List<MultipartBody.Part>): Single<SuccessBaseResponseModel>

    @Multipart
    @POST("jobber/register/upload_doc")
    fun uploadDocument(@Part file : List<MultipartBody.Part>): Single<SuccessBaseResponseModel>

    @POST("jobber/comments")
    fun getCommentsOfJob(@Body body : GetCommentsRequestModel): Single<ResponseArrayModel<Comment>>


}