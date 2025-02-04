const fa = require("firebase-admin");
const { Request, DeviceInfo, Jobber, User, sequelize } = require("../../../database/models");
const Sequelize = require("sequelize");
const Op = Sequelize.Op;
const accountSid = process.env.TWILIO_ACCOUNT_SID;
const authToken = process.env.TWILIO_AUTH_TOKEN;
const client = require('twilio')(accountSid, authToken);

function getNotificationByState(state, region) {
    let notification;
    if (region === "en") {
        switch (state) {
            //Auth Messages
            case "accept-document":
                notification = {
                    title: "your document has been accepted",
                    body: "you can begin wia add a job and add to it services"
                };
                break;
            case "reject-document":
                notification = {
                    title: "your document rejected",
                    body: "you can send another document to jobloyal"
                };
                break;

            //Request Messages
            case "accepted":
                notification = {
                    title: "Request Has Been Accepted",
                    body: "request accepted and you can pay to jobber"
                };
                break;
            case "canceled-by-jobber":
                notification = {
                    title: "the request has been canceled by jobber",
                    body: "the jobber has been canceled the request and you should reserve another jobber"
                };
                break;
            case "no-answer-busy":
                notification = {
                    title: "your request canceled",
                    body: "the jobber accepted another request and your request canceled automatically"
                };
                break;
            case "no-answer-free":
                notification = {
                    title: "your request canceled",
                    body: "the jobber not answer your request and your request has been canceled automatically"
                };
                break;
            case "arrived":
                notification = {
                    title: "jobber arrived near you",
                    body: "jobber had been arrived near of your pin location"
                };
                break;
            case "started":
                notification = {
                    title: "jobber started",
                    body: "jobber started your services"
                };
                break;
            case "finished":
                notification = {
                    title: "jobber finished",
                    body: "your services are finished by jobber"
                };
                break;
            case "rejected":
                notification = {
                    title: "your request rejected",
                    body: "jobber reject your request"
                };
                break;

            //User Action
            case "created":
                notification = {
                    title: "A New Request Has Been Created",
                    body: "you have a new request"
                };
                break;
            case "canceled-by-user":
                notification = {
                    title: "Request Has been canceled by User",
                    body: "the last request had been canceled by user"
                };
                break;
            case "verified":
                notification = {
                    title: "Request Verified",
                    body: "the request has been verified and amount of request will go to your credit"
                };
                break;
            case "paid":
                notification = {
                    title: "Request Paid",
                    body: "user paid your money for accepted request"
                };
                break;
            case "done":
                break;
        }
    }
    else {
        switch (state) {
            //Auth Messages
            case "accept-document":
                notification = {
                    title: "votre document a été accepté",
                    body: "vous pouvez commencer à ajouter un travail et y ajouter des services"
                };
                break;
            case "reject-document":
                notification = {
                    title: "votre document rejeté",
                    body: "vous pouvez envoyer un autre document à jobloyal"
                };
                break;

            //Request Messages
            case "accepted":
                notification = {
                    title: "La demande a été acceptée",
                    body: "demande acceptée et vous pouvez payer au jobber"
                };
                break;
            case "canceled-by-jobber":
                notification = {
                    title: "la demande a été annulée par le jobber",
                    body: "le jobber a annulé la demande et vous devez réserver un autre jobber"
                };
                break;
            case "no-answer-busy":
                notification = {
                    title: "votre demande annulée",
                    body: "le jober a accepté une autre demande et votre demande a été annulée automatiquement"
                };
                break;
            case "no-answer-free":
                notification = {
                    title: "votre demande annulée",
                    body: "le jobber ne répond pas à votre demande et votre demande a été annulée automatiquement"
                };
                break;
            case "arrived":
                notification = {
                    title: "jober est arrivé près de chez vous",
                    body: "jobber est arrivé près de votre emplacement d'épingle"
                };
                break;
            case "started":
                notification = {
                    title: "jober a commencé",
                    body: "jobber a commencé vos services"
                };
                break;
            case "finished":
                notification = {
                    title: "jobber fini",
                    body: "vos services sont terminés par jobber"
                };
                break;
            case "rejected":
                notification = {
                    title: "votre demande rejetée",
                    body: "jober rejeter votre demande"
                };
                break;

            //User Action
            case "created":
                notification = {
                    title: "Une nouvelle demande a été créée",
                    body: "vous avez une nouvelle demande"
                };
                break;
            case "canceled-by-user":
                notification = {
                    title: "La demande a été annulée par l'utilisateur",
                    body: "la dernière demande a été annulée par l'utilisateur"
                };
                break;
            case "verified":
                notification = {
                    title: "Demande vérifiée",
                    body: "la demande a été vérifiée et le montant de la demande sera porté à votre crédit"
                };
                break;
            case "paid":
                notification = {
                    title: "Demande payée",
                    body: "l'utilisateur a payé votre argent pour une demande acceptée"
                };
                break;
            case "done":
                break;
        }
    }
    // if (notification) notification.sound = "default";
    return notification
}
function sendSMSToJobber(phoneNumber) {
    // client.messages
    //     .create({body: 'Hi, you have a new request and you can accept it til 5 minute later', from: '+15017122661', to: phoneNumber})
    //     .then(message => console.log(message.sid));
}
async function sendMessage(type, request, jobberAndUser, exceptDeviceId) {
    const jobberFCMs = await getAllFcmTokensOfUserId(request.jobber_id, exceptDeviceId);
    const userFCMs = await getAllFcmTokensOfUserId(request.user_id, exceptDeviceId);
    if (type === 'update') {
        const UpdateNotificationLifeTime = {
            ttl: (process.env.UPDATE_NOTIFICATION_LIFE_TIME * 60 * 1000),
            collapseKey: 'update',
        };
        let userMessage = {
            data: { is_jobber_app: "false", method: 'UPT' },
            tokens: userFCMs,
            ...UpdateNotificationLifeTime,
        };
        let jobberMessage = {
            data: { is_jobber_app: "true", method: 'UPT' },
            tokens: jobberFCMs,
            ...UpdateNotificationLifeTime,
        };

        //Jobber Send ACT
        if (request.status === "accepted" ||
            request.status === "canceled-by-jobber" ||
            request.status === "no-answer-busy" ||
            request.status === "no-answer-free" ||
            request.status === "arrived" ||
            request.status === "started" ||
            request.status === "finished" ||
            request.status === "rejected") {
            if (request.status === "canceled-by-jobber" ||
                request.status === "no-answer-busy" ||
                request.status === "no-answer-free" ||
                request.status === "rejected") {
                userMessage.data.method = "CNL"
            }
            userMessage.notification = getNotificationByState(request.status, jobberAndUser.user.region)
            if (userMessage.notification)
                userMessage.apns = { payload: { aps: { sound: 'default' } } };
        }
        //User Send ACT
        else if (request.status === "canceled-by-user" ||
            request.status === "canceled-by-user-prepay" ||
            request.status === "verified" ||
            request.status === "paid") {
            jobberMessage.notification = getNotificationByState(request.status, jobberAndUser.jobber.region);
            if (jobberMessage.notification)
                jobberMessage.apns = { payload: { aps: { sound: 'default' } } };
            if (request.status === "canceled-by-user-prepay") {
                jobberMessage.data.method = "CNL";
                jobberMessage.priority = "high";
                jobberMessage.mutableContent = true;
                jobberMessage.contentAvailable = true;
                jobberMessage.data.data = JSON.stringify({ request_id: request.id });

            }
        }
        if (userFCMs.length > 0) push(userMessage);
        if (jobberFCMs.length > 0) push(jobberMessage);
    }
    else if (type === 'add') {
        let userMessage = {
            data: { is_jobber_app: "false", method: 'NEW' },
            tokens: userFCMs,
            ttl: 0,
        };
        const data = JSON.stringify({
            ...((await getLastAddedRequest(jobberAndUser.jobber.id, jobberAndUser.jobber.region, true))[0]),
            request_life_time: process.env.REQUEST_LIFE_TIME * 60
        });
        let jobberMessage = {
            data: {
                is_jobber_app: "true",
                method: 'NEW',
                data: data
            },
            tokens: jobberFCMs,
            ttl: (process.env.REQUEST_LIFE_TIME * 60) * 1000
        };
        if (jobberAndUser.jobber.notification_enabled === true) {
            jobberMessage.notification = getNotificationByState(request.status, jobberAndUser.jobber.region);
            jobberMessage.apns = { payload: { aps: { sound: 'default' } } };
        }
        if (jobberFCMs.length > 0)
            push(jobberMessage);
        if (userFCMs.length > 0)
            push(userMessage);
        if (jobberAndUser.jobber.sms_enabled === true)
            sendSMSToJobber(jobberAndUser.jobber.phone_number);
    }
}

async function getUserAndJobber(jobber_id, user_id) {
    let jobber = [null];
    let user = [null];
    if (jobber_id) {
        jobber = await sequelize.query('SELECT jobber.id, jobber.region, jobber.name, jobber.phone_number, jobber.family,jobber.gender,js.sms_enabled, js.notification_enabled FROM public."Jobbers" as jobber LEFT OUTER JOIN public."JobberStatics" as js ON js.jobber_id = jobber.id where jobber.id = :jobber_id LIMIT 1', {
            replacements: {
                jobber_id: jobber_id
            },
            raw: true,
            nest: true
        });
    }
    if (user_id) {
        user = await sequelize.query('SELECT "user".id, "user".region, "user".name, "user".family,"user".gender FROM public."Users" as "user" WHERE "user".id = :user_id LIMIT 1', {
            replacements: {
                user_id: user_id
            },
            raw: true,
            nest: true
        });
    }
    return { jobber: jobber[0], user: user[0] }
}

function push(message) {
    fa.messaging().sendMulticast(message)
        .then((response) => {
            if (response.failureCount > 0) {
                const failedTokens = [];
                response.responses.forEach((resp, idx) => {
                    if (!resp.success) {
                        failedTokens.push(idx);
                    }
                });
                console.log('List of tokens that caused failures: ' + failedTokens);
            }
        });
}


async function getAllFcmTokensOfUserId(UserId, exceptDeviceId) {
    let whereCondition = {
        where: {
            user_id: UserId,
        }
    };
    if (exceptDeviceId)
        whereCondition.where.id = { [Op.ne]: exceptDeviceId };
    const tokens = await DeviceInfo.findAll({
        ...whereCondition,
        attributes: ['fcm'],
        raw: true
    });
    console.log(tokens);
    return tokens.flatMap((e) => e.fcm || [])
}
module.exports = {

    pushNotificationForRequest: async (request_id, user_device_id, newStatus) => {
        const request = await Request.findOne({
            where: {
                id: request_id
            },
            raw: true,
            nest: true
        });
        if (newStatus)
            request.status = newStatus;
        const userAndJobber = await getUserAndJobber(request.jobber_id, request.user_id);
        if (request.status === 'created') {
            await sendMessage('add', request, userAndJobber, user_device_id)
        }
        else {
            await sendMessage('update', request, userAndJobber, user_device_id)
        }
    },

    pushNotificationForJobberAuthorize: async (jobber_id, status) => {
        const { jobber } = getUserAndJobber(jobber_id);
        const jobberFCMs = await getAllFcmTokensOfUserId(jobber_id);
        let message = {};
        message.notification = getNotificationByState(status, jobber.region);
        message.tokens = jobberFCMs;
        message.data = { method: 'DSP' };
        fa.messaging().send(message)
            .then((response) => {
                console.log('Successfully sent message:', response);
            })
            .catch((error) => {
                console.log('Error sending message:', error);
            });
    }

};
