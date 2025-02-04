const PaymentController = require("../../payment/payment.controller");
const messages = require("../../../../helper/message.helper");
const {Request, JobberDailyStatus,Rate } = require("../../../../database/models");
const exec = require("child_process").exec;
const {pushNotificationForRequest} = require("../../notification/notification.controller");



module.exports = {
    payRequest: async function (req,res){
        const user_id = req.user.id;
        const {use_wallet} = req.body;
        const lastRequest = await PaymentController.getLastPayableRequest(user_id);
        if (lastRequest) {
            const amounts = await PaymentController.getPayableAmountOfRequest(user_id, lastRequest.id);
            if (amounts) {
                const link = await PaymentController.createPaymentLinkForRequest(user_id, lastRequest.id, amounts.totalPayable, use_wallet);
                res.scaffold.add(link);
                if (link.paid === true) {
                    pushNotificationForRequest(lastRequest.id, req.user.device)
                }
            } else {
                res.scaffold.failed(messages.notFound)
            }
        } else {
            res.scaffold.failed(messages.notAnyRequestFound)
        }
    },

    checkAfterPay: async function (req,res) {
        const user_id = req.user.id;
        const lastRequest = await PaymentController.getLastPayableRequestAsModel(user_id);
        if (lastRequest) {
            const result = await PaymentController.validationOfPayment(lastRequest);
            res.scaffold.add(result);
            if (result.isNewRecord === true) {
                pushNotificationForRequest(result.request_id,req.user.device)
            }
        }
        else {
            res.scaffold.failed(messages.notAnyRequestFound)
        }

    },

    stripeWebHook: async function(req, res) {
        const authority = req.body.data.object.id;
       if (authority) {
           const result = await PaymentController.validateWithAuthority(authority);
           res.scaffold.add(result);
           if (result.isNewRecord === true) {
               pushNotificationForRequest(result.request_id)
           }
       }
       else {
           res.scaffold.failed()
       }
    },

    //TEST ONLY
    calculateDeposits: async function(req,res) {
        const pc = await PaymentController.deposit();
        res.scaffold.add(pc)
    },

    testPayRequest: async function (req, res) {
        await Request.update({
            paid: true,
            status: "paid"
        }, {
            where: {
                user_id: req.user.id,
                time_base: false,
                status: 'accepted'
            }
        });
        res.scaffold.success()
    },
    depositExec : async function (req, res) {
        const result = await PaymentController.sendDepositsToBank();
        res.scaffold.add(result)
    },
    depositReport: async function (req, res) {
      const {start,end} = req.body;
      const obj = await PaymentController.getReportFromRequestControlPanel(start,end);
      res.scaffold.add(obj)
    },

    verifyRequest: async function (req, res) {
        const request = await Request.findOne({
            where: {
                user_id: req.user.id,
                status: 'finished',
                paid: true,
                time_base: false
            },
            order: [['created_at', 'desc']],
            limit: 1
        });
        if (request) {
            await PaymentController.freeJobber(request.dataValues.job_id,request.dataValues.jobber_id);
            request.status = 'verified';
            await request.save();
            res.scaffold.success();
            pushNotificationForRequest(request.dataValues.id, req.user.device)
        }
        else {
            res.scaffold.failed(messages.notAnyRequestFound)
        }
    }
};
