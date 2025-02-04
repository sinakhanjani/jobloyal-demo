const accountSid = process.env.TWILIO_ACCOUNT_SID;
const authToken = process.env.TWILIO_AUTH_TOKEN;
const client = require('twilio')(accountSid, authToken);
const messages = require("../../../helper/message.helper");
const jwt = require('jsonwebtoken');

send = async function (req,res) {
    if (req.body.phoneNumber.length === 12) {
        let localeCode = 'en';
        if (req.body.phoneNumber.startsWith("+33") || req.body.phoneNumber.startsWith("+41")) {
            localeCode = 'fr';
        }
        else {
            localeCode = 'en';
        }
        client.verify.services('VA3ea3563718e40709050efeeddf586bde')
            .verifications
            .create({to: req.body.phoneNumber, channel: 'sms',locale: localeCode})
            .then(verification => {
                res.scaffold.success()
            }).catch(e => {
                console.log(e)
        });
    }
    else {
        res.scaffold.failed(messages.phoneCondition)
    }
};

check = async function (req,res) {
    if (req.body.code.length !== 6) {
        res.scaffold.failed(messages.expiredCode)
    }
    if (req.body.phoneNumber.length === 12) {
        client.verify.services('VA3ea3563718e40709050efeeddf586bde')
            .verificationChecks
            .create({to: req.body.phoneNumber, code: req.body.code})
            .then(verification_check => {
                if (verification_check.status === "approved") {
                    const token = generateToken(req.body.phoneNumber);
                    res.scaffold.add({token})
                }
                else {
                    // const token = generateToken(req.body.phoneNumber);
                    // res.scaffold.add({token})
                    res.scaffold.failed(messages.expiredCode)
                }
            }).catch(err => {
                res.scaffold.failed(messages.expiredCode)
            });
    }
    else {
        res.scaffold.failed(messages.phoneCondition)
    }
};

generateToken = function (phoneNumber) {
    return jwt.sign({
        phoneNumber: phoneNumber
    }, process.env.JWT_SECRET_PHONE_AUTH, { expiresIn: '12m' });
};

module.exports = {
    send,
    check
};
