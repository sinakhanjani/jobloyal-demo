const express = require('express');
const router = new express.Router();

const structure = require('../../middlewaire/response.structure');
const registration = require('./registration/jobber.register');
const job = require('./job/jobber.job.controller');
const {getAllJobInCategory} = require('../admin/job/job.controller');
const unit = require('./service/unit/unit.controller');
const service = require('./service/service.controller');
const comments = require('./comments/jobber.comment.controller');
const auth = require('../../middlewaire/auth.jobber');
const admin = require('../../middlewaire/auth.admin');
const status = require("./profile/status");
const dailyStatus = require("./daily/daily.status");
const locationJobber = require("./daily/jobber.location");
const request = require("./request/jobber.request.controller");
const uploadAvatar = require("../../../helper/multer.helper");
const uploadDocument = require("../../../helper/multer.helper");
const messenger = require("../common/message/common.message");
const deviceController = require("../common/device.info/device.controller");
const suspend = require("../common/suspend/suspend.detail");
const reportController = require("./report/report.controller");
const profileController = require("./profile/jobber.profile.controller");
const {getCategories} = require("../admin/category/category.controller");


router.post('/register/get_token',structure, registration.getToken);
router.post('/register/register',structure, registration.registerStep1);
router.post('/delete-account',auth, registration.deleteJobber);
router.post('/register/upload_avatar',[auth,uploadAvatar.single('avatar')], registration.uploadAvatarForUser);
router.post('/register/upload_doc',[auth,uploadDocument.single('doc')], registration.uploadDocument);
router.get('/register/step_auth',[auth], registration.checkStepAuthorized);
router.post('/register/complete_profile',[auth], registration.completeProfile);
router.post('/register/check_available_id',structure, registration.checkAvailableIdentifier);

router.get("/profile",auth,registration.getProfileJobber);
router.post("/profile/update",auth,registration.editProfile);

router.post("/profile/edit_notification",auth,profileController.updateNotificationInfo);
router.post("/profile/edit_payment",auth,profileController.updatePaymentInfo);

router.post("/profile/edit_region",auth,registration.changeRegionRequest);

router.post("/job/add",auth,job.add);
router.get("/job/myjobs",auth,job.getAllJobs);
router.post("/job/page",auth,job.getJobPage);
router.post("/job/get",auth,getAllJobInCategory);
router.post("/job/delete",auth,job.delete);

router.get('/categories',auth,getCategories);

router.post("/unit/add",auth,unit.create);
router.post("/unit/search",auth,unit.search);
router.get("/unit/all",auth,unit.getAll);

router.post("/service/create",auth,service.create);
router.post("/service/get",auth,service.getAllInJobId);
router.post("/service/search",auth,service.search);
router.post("/service/add",auth,service.addServiceToJobber);
router.post("/service/delete",auth,service.deleteServiceFromJobber);
router.get("/service/myservices",auth,service.getAllServicesOfJobber);

router.post("/comments",auth,comments.getComments);

router.post("/status/add",auth,dailyStatus.create);
router.get("/status/get",auth,dailyStatus.get);
router.post("/status/location/add",auth,locationJobber.create);
router.get("/status/location/get",auth,locationJobber.getLastLocation);

router.get("/suspend/detail",auth,suspend.getDetail);

router.post('/device/add',auth,deviceController.addDeviceInfo);
router.post('/device/logout',auth,registration.logout);

router.post('/message/send',auth,messenger.create);
router.get('/messages',auth,messenger.get);

router.get("/request/status_last_request",auth,request.getStatusOfLastRequest);
router.get("/request/myrequest",auth,request.getMyRequests);
router.post("/request/accept",auth,request.acceptRequest);
router.post("/request/reject",auth,request.rejectRequest);
router.post("/request/cancel",auth,request.cancelLastRequest);
router.post("/request/arrive",auth,request.arriveJobber);
router.post("/request/start",auth,request.startJob);
router.post("/request/finish",auth,request.finishJob);
router.get("/request/location/:request_id",auth,request.getLocationOfRequest);

router.post("/report",auth,reportController.getReports);
router.get("/report/:id",auth,reportController.getServicesOfRequest);

router.get("/turnover",auth,reportController.getTurnover);

module.exports = router;
