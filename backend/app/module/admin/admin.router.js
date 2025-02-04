const express = require('express');
const structure = require('../../middlewaire/response.structure');
const job = require("./job/job.router");
const login = require("./auth/admin.login");
const category = require("./category/category.router");
const admin = require("../../middlewaire/auth.admin");
const unit = require("../jobber/service/unit/unit.controller");
const service = require("../jobber/service/service.controller");
const admin_service = require("./service/admin.service.controller");
const messenger = require("./message/message.controller");
const suspend = require("./suspend/suspend.controller");
const user = require("./user/admin.user.controller");
const jobber = require("./jobber/admin.jobber.controller");
const request = require("./requests/admin.request.controller");
const report = require("./report/admin.report.controller");
const payReport = require("./report/payment.report.controller");
const pushNotif = require("./notification/push.notification");
const jobberAuthenticationController = require("./jobber/verification/jobber.verification.controller");
const ver = require("../common/version.control/version.controller");
const {depositReport} = require("../user/payment/pay.controller");

const router = new express.Router();

router.use('/job', job);
router.use('/category', category);
router.post('/login',structure, login.login);
router.get('/login_with_token',admin, login.loginWithToken);

router.post("/unit/delete",admin,unit.delete);
router.post("/unit/search",admin,unit.search);
router.get("/unit/all",admin,unit.getAll);
router.post("/unit/edit",admin,unit.edit);
router.post("/unit/create",admin,unit.create);

router.post("/service/delete",admin,service.delete);
router.post("/service/all",admin,service.getAllInJobId);
router.post("/service/anything",admin,service.getAll);
router.post("/service/create",admin,service.create);
router.post("/service/edit",admin,admin_service.edit);

router.post("/suspend/add",admin,suspend.suspendUser);
router.post("/suspend/delete",admin,suspend.deleteSuspend);

router.post("/version/add",admin,ver.addVersion);
router.get("/version/all",admin,ver.getAllVersions);
router.post("/version/delete",admin,ver.deleteVersion);

router.post("/request/get",admin,request.getRequestByID);
router.post("/request/all",admin,request.getAll);
router.post("/request/search",admin,request.search);

router.post("/users",admin,user.getAll);
router.post("/users/search",admin,user.searchUser);
router.get("/user/:id",admin,user.getUserByUserId);


router.post("/jobbers",admin, jobber.getAll);
router.post("/jobbers/search",admin,jobber.searchJobber);
router.post("/jobber/edit",admin,jobber.editIban);
router.get("/jobber/:id",admin, jobber.getJobberById);
router.post("/jobber/auth/verify",admin, jobberAuthenticationController.acceptJobber);
router.post("/jobber/auth/reject",admin, jobberAuthenticationController.rejectJobber);
router.get("/jobber/auth/all",admin, jobberAuthenticationController.getJobbersPendingDocument);
router.post("/jobber/auth/search",admin, jobberAuthenticationController.searchDocuments);
router.get("/jobber/auth/:id",admin, jobberAuthenticationController.getJobberDocument);

router.post("/reports",admin, report.getReport);

router.post("/payments/report",admin, payReport.getAllPayments);
router.post("/payments/search",admin, payReport.searchPayments);
router.post("/deposits/report",admin, payReport.getAllDeposits);
router.post("/deposits/search",admin, payReport.searchDeposits);
router.post("/failure-deposits/report",admin, payReport.getAllFailedDeposit);
router.post("/failure-deposits/search",admin, payReport.searchFailedDeposit);
router.post("/bank/report",admin, depositReport);

router.post("/notification/push",admin, pushNotif.sendNotification);

router.post("/message/reply",admin,messenger.sendReply);
router.post("/messages",admin,messenger.getAllMessage);
router.post("/message",admin,messenger.getMessage);

module.exports = router;
