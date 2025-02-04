const {JobberStatic} = require("../../../../database/models");
const IBAN = require('iban');
const messages = require("../../../../helper/message.helper");

module.exports = {

    updatePaymentInfo: async (req, res) => {
        const {iban, period} = req.body;
        try {
            if (IBAN.isValid(iban)) {
                const result = await JobberStatic.update({
                    card_number: iban.replace(/\s+/g,""),
                    pony_period: period
                }, {
                    where: {
                        jobber_id: req.user.id
                    }
                });
                res.scaffold.success()
            }
            else {
                res.scaffold.failed(messages.ibanIsInvalid)
            }
        }
        catch (e) {
            res.scaffold.failed(e.message)
        }
    },

    updateNotificationInfo: async (req, res) => {
        const {sms, notification} = req.body;
        try {
            const result = await JobberStatic.update({
                sms_enabled: sms,
                notification_enabled: notification
            }, {
                where: {
                    jobber_id: req.user.id
                }
            });
            if (result[0] === 0) {
                await JobberStatic.create({
                    jobber_id: req.user.id,
                    sms_enabled: sms,
                    notification_enabled: notification,
                    pony_period: 1,
                    card_number: ''
                });
            }
            res.scaffold.success()
        }
        catch (e) {
            res.scaffold.failed(e.message)
        }
    }
}
