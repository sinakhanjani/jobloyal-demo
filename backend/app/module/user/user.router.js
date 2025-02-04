const express = require('express');
const router = new express.Router();
const structure = require('../../middlewaire/response.structure');
const registration = require("./registration/user.register");
const auth = require("../../middlewaire/auth.user");
const {getCategories} = require("../admin/category/category.controller");
const {getAllJobInCategory} = require("../admin/job/job.controller");
const onlineJobbers = require("./jobber/online.jobber");
const request = require("./request/user.request.controller");
const service = require("./service/service.controller");
const comments = require("./comment/user.comment.controller");
const jobberPage = require("./jobber/jobber.page");
const messenger = require("../common/message/common.message");
const suspend = require("../common/suspend/suspend.detail");
const deviceController = require("../common/device.info/device.controller");
const paymentController = require("./payment/pay.controller");
const walletController = require("./wallet/wallet.controller");

router.post('/register/get_token',structure, registration.getToken);
router.post('/register/register',structure, registration.registerUser);
router.post('/delete-account',auth, registration.deleteUser);
router.post('/profile/edit',auth, registration.editProfile);
router.get('/profile',auth, registration.getProfile);

router.post("/profile/edit_region",auth,registration.changeRegionRequest);

router.get('/categories',auth,getCategories);
router.post('/jobs',auth,getAllJobInCategory);

router.post('/jobber/find_by_job',auth,onlineJobbers.findByJob);
router.post('/jobber/find_by_service',auth,onlineJobbers.findByService);

router.post('/request/add',auth,request.create);
router.get('/request/page/:request_id',auth,request.getRequestDetail);
router.get('/request/last_request_detail',auth,request.getLastRequestDetail);
router.get('/request/status_last_request',auth,request.getStatusOfRequest);
router.post('/request/cancel',auth,request.cancelLastRequest);

router.get('/wallet',auth, walletController.getWalletCredit);


router.post('/service/search',auth,service.search);
router.post('/service/reserved_services',auth,service.listOfReservedServices);
router.post('/service/canceled_services',auth,service.listOfCanceledServices);

router.post('/payment/pay',auth,paymentController.payRequest);
router.post('/payment/check-pay',auth,paymentController.checkAfterPay);
router.post('/payment/webhook',paymentController.stripeWebHook);

// router.post('/payment/test-pay',auth,paymentController.testPayRequest);
// router.post('/payment/deposit-test',structure, paymentController.depositExec);
// router.post('/payment/report-test',structure, paymentController.depositReport);
// router.get('/payment/calculateDeposits',auth,paymentController.calculateDeposits);
router.post('/payment/verify-pay',auth,paymentController.verifyRequest);

router.get("/suspend/detail",auth,suspend.getDetail);

router.post('/message/send',auth,messenger.create);
router.get('/messages',auth,messenger.get);

router.post('/device/add',auth,deviceController.addDeviceInfo);
router.post('/device/logout',auth,deviceController.logout);

router.post('/comment/submit',auth,comments.submit);
router.post('/comments',auth,comments.getComments);

router.post('/jobber/page',auth,jobberPage.getPage);



module.exports = router;
