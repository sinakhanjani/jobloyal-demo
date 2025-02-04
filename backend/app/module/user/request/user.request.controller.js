const {Request,Sequelize,JobberService,Jobber,sequelize,RequestService,JobberDailyStatus} = require("../../../../database/models");
const axios = require('axios');
const Op = Sequelize.Op;
const messages = require('../../../../helper/message.helper');
const {getTotalPayableForRequestWithWallet,refundPayment} = require("../../payment/payment.controller");
const {pushNotificationForRequest} = require("../../notification/notification.controller");

checkAllServicesHasUnit = function (fetchedServices) {
    let allServicesHasUnit = true;
    const jobId = fetchedServices[0].job_id;
    for (service of fetchedServices) {
        if (service.unit_id === null || jobId !== service.job_id) //check all services from one job
            allServicesHasUnit = false
    }
    return allServicesHasUnit
};

checkCorrectServices = function (fetchedServices) {
    return (fetchedServices.length > 1 && checkAllServicesHasUnit(fetchedServices)) || (fetchedServices.length === 1)
};

calculation = function (userServices,services) {
    let reservingService = services.filter(e => {
        const included = userServices.findIndex(item => item.id === e.id);
        if (included >= 0) {
            console.log(e.unit_id)
            e.count = e.unit_id != null ? (userServices[included].count || 1) : 1

        }
        return included >= 0
    });
    let total = 0;
    reservingService.forEach(e => {
        total += e.price * e.count;
        delete e.jobber_id;
        delete e.job_id;
        e.accepted = false;
        e.service_id = e.id;
        delete e.id;
        delete e.unit_id;
        e.price = e.price * e.count;
    });
    return {total,reservingService}
};
userNotHaveLiveRequest = async function (userID) {
    const request = await Request.findOne({
        where: {
            user_id: userID
        },
        order: [['created_at','DESC']]
    });
    if (request === null) {
        return true;
    } else {
        return (request.status === 'created' &&
            request.createdAt < new Date(Date.now() - 60000 * parseInt(process.env.REQUEST_LIFE_TIME))) ||
            request.status === 'canceled-by-user' ||
            request.status === 'canceled-by-jobber' ||
            request.status === 'no-answer-busy' ||
            request.status === 'deposited' ||
            request.status === 'rejected' ||
            request.status === 'done';
            // request.status === 'verified'; //he should request and go to done state
    }
};
jobberIsFreeAndOnline = async function (jobberID,jobID) {
    const today = new Date().toISOString().substring(0, 10);
    const checkJobberIsAvailable = await JobberDailyStatus.findOne({
        where: {
            jobber_id: jobberID,
            job_id: jobID,
            created_at: {[Op.gte]: today}
        },
        order: [['id', 'DESC']]
    });
    return checkJobberIsAvailable !== null && checkJobberIsAvailable.status === 'online'

};

module.exports = {
    create: async function (req,res) {
        const userId = req.user.id;
        const {jobberId,longitude,latitude,arrivalTime,services} = req.body;
        if (await userNotHaveLiveRequest(userId) === true) {
            const fetchedServices = await JobberService.findAll({
                where: {
                    id: {
                        [Op.in]: services.map(e => {
                            return e.id
                        })
                    }, jobber_id: {[Op.eq]: jobberId}
                },
                attributes: ["id", "price", "unit_id", "jobber_id", "job_id"],
                raw: true
            });
            if (fetchedServices.length > 0 && fetchedServices[0] !== null && await jobberIsFreeAndOnline(jobberId,fetchedServices[0].job_id) === true) {
                if (checkCorrectServices(fetchedServices)) {
                    const isTimeBaseRequest = !fetchedServices[0].unit_id;
                    const jobId = fetchedServices[0].job_id;
                    const calculated = calculation(services, fetchedServices);
                    let total = 0;
                    if (!isTimeBaseRequest) {
                        total = calculated.total
                    } else {
                        total = fetchedServices[0].price
                    }
                    try {
                        const earth = await sequelize.query("SELECT ll_to_earth(:latitude, :longitude) as location",
                            {
                                replacements: {
                                    latitude: latitude,
                                    longitude: longitude
                                }
                            });
                        let address = null;
                        try {
                            const geocoding = await axios.get(`https://api.codezap.io/v1/reverse?lat=${latitude}&lng=${longitude}`,
                                {headers: {"api-key": process.env.API_KEY_CODEZAP}});
                            if (geocoding.data.address) {
                                address = geocoding.data.address.road || geocoding.data.address.suburb
                            }
                        }
                        catch (e) {
                            address = "unknown";
                        }
                        const request = await Request.create({
                            "jobber_id": jobberId,
                            "user_id": userId,
                            "price": total,
                            "status": 'created',
                            "location": earth[0][0].location,
                            "address": address,
                            "paid": false,
                            "arrival_time": arrivalTime,
                            "time_base": isTimeBaseRequest,
                            "job_id": jobId
                        });

                        calculated.reservingService.forEach(e => e.request_id = request.id);
                        if (isTimeBaseRequest) {
                            calculated.reservingService[0].count = 0
                        }
                        await RequestService.bulkCreate(calculated.reservingService);
                        res.scaffold.add({items: calculated.reservingService,request_life_time: process.env.REQUEST_LIFE_TIME * 60});
                        pushNotificationForRequest(request.id, req.user.device)
                    } catch (e) {
                        res.scaffold.failed(e)
                    }
                } else {
                    res.scaffold.failed(messages.serviceIdWantSameType)
                }
            }
            else {
                res.scaffold.failed(messages.jobberNotAvailable)
            }
        }
        else {
            res.scaffold.failed(messages.userHaveLiveRequest)
        }
    },

    /*
    * Remaining Time: if status of request has been `created`, means remain time waiting to answer the jobber
    * Remaining Time: if status of request has been `accepted`, means remain time for paying the money for pre-pay services
    * and on other statuses it was NULL
    * */
    getStatusOfRequest : async function(req,res) {
        const userId = req.user.id;
        const region = req.user.region;
        const request = await sequelize.query('SELECT longitude("Request"."location"),latitude("Request"."location"), "Request"."id" as "request_id","Request"."status", "Request"."createdAt" as created_at,EXTRACT(EPOCH FROM "Request"."createdAt" - ( NOW() - INTERVAL :req_time_life))::INT as remaining_time,EXTRACT(EPOCH FROM "Request"."updatedAt" - ( NOW() - INTERVAL :user_pay_time))::INT as remaining_time_to_pay, "job"."title"->:region AS "job_title" ,"jobber"."id" AS "jobber.id", "jobber"."identifier" AS "jobber.identifier", "jobber"."avatar" AS "jobber.avatar", "jobber"."name" AS "jobber.name", "jobber"."family" AS "jobber.family", COUNT("request_services"."id") AS "service_count" FROM (SELECT "Request"."id","Request"."location","Request"."job_id", "Request"."status", "Request"."created_at" AS "createdAt","Request"."updated_at" AS "updatedAt", "Request"."jobber_id" FROM "Requests" AS "Request" WHERE "Request"."user_id" = :user_id AND (("Request"."status" = \'finished\' OR "Request"."status" = \'created\' OR "Request"."status" = \'verified\' OR "Request"."status" = \'paid\'  OR "Request"."status" = \'accepted\' OR "Request"."status" = \'arrived\' OR "Request"."status" = \'started\')) ORDER BY "Request"."created_at" DESC LIMIT 1) AS "Request" LEFT OUTER JOIN "Jobbers" AS "jobber" ON "Request"."jobber_id" = "jobber"."id" LEFT OUTER JOIN "RequestServices" AS "request_services" ON "Request"."id" = "request_services"."request_id" LEFT OUTER JOIN "Jobs" AS "job" ON "Request"."job_id" = "job"."id" GROUP BY "Request"."location","Request"."id","jobber" ."id","Request"."createdAt","Request"."status","Request"."job_id","job"."title","Request"."updatedAt" ORDER BY "createdAt" DESC',{
            replacements: {
                user_id:userId,
                region: region,
                req_time_life: `${process.env.REQUEST_LIFE_TIME} minutes`,
                user_pay_time: `${process.env.USER_TIME_PAYING} minutes`
            },
            nest:true,
        });
        if (request.length > 0) {
            const lastRequest = request[0];
            if ((lastRequest.status === 'created' && lastRequest.remaining_time <= 0) || lastRequest.status === 'canceled-by-user' ||  lastRequest.status === 'rejected' || lastRequest.status === 'canceled-by-jobber' || lastRequest.status === 'done'  || lastRequest.status === 'no-answer-busy' || lastRequest.status === 'no-answer-free')
                res.scaffold.success();
            else {
                if (lastRequest.status === 'created') {
                    lastRequest.jobber.id =
                    lastRequest.jobber.avatar =
                    lastRequest.jobber.name =
                    lastRequest.jobber.family = null;
                }
                else if (lastRequest.status === 'accepted')
                    lastRequest.remaining_time = lastRequest.remaining_time_to_pay;
                 else
                    lastRequest.remaining_time = null;
                lastRequest.tag = lastRequest.status;
                console.log(lastRequest)
                lastRequest.total_pay = (await getTotalPayableForRequestWithWallet(userId,lastRequest.request_id));
                lastRequest.request_life_time = process.env.REQUEST_LIFE_TIME * 60;
                lastRequest.user_time_paying = process.env.USER_TIME_PAYING * 60;
                lastRequest.remaining_time_to_pay = undefined;
                res.scaffold.add(lastRequest)
            }
        }
        else {
            res.scaffold.success()
        }
    },

    getRequestDetail: async function (req,res) {
        const request_id = req.params.request_id;
        if (request_id) {
            try {
                const requestPage = await sequelize.query('SELECT request.job_id as job_id,request.status as status,request.paid, request.updated_at + INTERVAL \'1 minute\' *  request.arrival_time as arrival_time, request.time_base,jobber.id as "page.id", CONCAT(jobber.name,\' \',jobber.family) as "page.name", jobber.identifier as "page.identifier", jobber.avatar as "page.avatar", jobber.about_us as "page.about_me", jobber.phone_number as "page.phone_number", rate.rate as "page.rate", rate.work as "page.work_count", EXTRACT(EPOCH FROM request.updated_at - ( NOW() - INTERVAL :user_pay_time))::INT as remaining_time, (rate.star1 + rate.star2 + rate.star3 + rate.star4 + rate.star5) as "page.total_comments", json_agg(services) as "services" From "Requests" as request INNER JOIN "Jobbers" as jobber on request.jobber_id = jobber.id LEFT OUTER JOIN "Rates" as rate on request.jobber_id = rate.jobber_id and rate.job_id = request.job_id INNER JOIN (SELECT S.title as title,rs.count as count, js.price as price,rs.price as total_price,rs.accepted as accepted,unit.title as unit,rs.request_id from "RequestServices" rs LEFT OUTER JOIN "JobberServices" js on js.id = rs.service_id LEFT OUTER JOIN "Services" S on js.service_id = S.id LEFT OUTER JOIN "Units" unit on js.unit_id = unit.id) as services on services.request_id = request.id WHERE request.id = :request_id AND request.user_id = :user_id GROUP BY request.arrival_time, request.time_base,jobber.id,jobber.name,jobber.family, jobber.identifier, jobber.avatar, jobber.about_us, rate.rate , rate.work, rate.star1 , rate.star2 , rate.star3 , rate.star4 ,request.paid, rate.star5,request.job_id,request.status, request.updated_at', {
                    replacements: {
                        request_id:request_id,
                        user_id: req.user.id,
                        user_pay_time: `${process.env.USER_TIME_PAYING} minutes`
                    },
                    nest: true
                });
                if (requestPage.length > 0) {
                    const page = requestPage[0];

                    if (page.status === 'created' || page.status === 'canceled-by-jobber' || page.status === 'canceled-by-user' || page.status === 'done' || page.status === 'no-answer-busy' || page.status === 'no-answer-free') {
                        res.scaffold.failed(messages.notAnyRequestFound)
                    } else {
                        if (page.status !== "paid" && page.status !== "accepted") {
                            page.remaining_time = null;
                            page.arrival_time = null;
                        }
                        if (page.status === "created" || (page.status === "accepted" && page.time_base === false)) {
                            page.page.phone_number = null
                        }
                        page.comments = await sequelize.query('SELECT comments.id,sv.title as service_title, comments.comment as comment, comments.rate as rate FROM public."Comments" as comments LEFT OUTER JOIN public."Services" as sv ON comments.service_id = sv.id WHERE comments.jobber_id = :jobber_id AND comments.job_id = :job_id AND comments.comment <> \'\' AND comments.comment IS NOT NULL ORDER BY comments.id DESC LIMIT 3', {
                            replacements: {
                                job_id: page.job_id,
                                jobber_id: page.page.id,
                            },
                            nest: true
                        });
                        page.total_time_interval = null;
                        if (page.status === "finished") {
                            const timeInterval = await sequelize.query('SELECT date_part(\'hour\', finished.created_at - started.created_at) * 60 + date_part(\'minute\', finished.created_at - started.created_at) as total_time_interval FROM "RequestStatusReport" as finished CROSS JOIN "RequestStatusReport" as started where started.status = \'started\' AND started.request_id = :request_id AND finished.status = \'finished\' AND finished.request_id = :request_id',{
                                replacements: {
                                    request_id: request_id
                                },
                                plain: true,
                                nest: true
                            });
                            page.total_time_interval = timeInterval.total_time_interval
                        }

                        page.total_pay = (await getTotalPayableForRequestWithWallet(req.user.id,request_id));
                        page.user_time_paying= process.env.USER_TIME_PAYING * 60;
                        page.services.forEach(e => {
                            e.is_paid = e.accepted === true && page.paid === true
                        });
                        page.paid = undefined;
                        res.scaffold.add(page)
                    }
                }
                else {
                    res.scaffold.failed(messages.notAnyRequestFound)
                }
            }
            catch (e) {
                res.scaffold.failed(e.message)
            }
        }
    },


    getLastRequestDetail: async function (req,res) {
            try {
                const requestPage = await sequelize.query('SELECT jobber.id as id, CONCAT(jobber.name,\' \',jobber.family) as "name", jobber.identifier as identifier, jobber.avatar as avatar, jobber.about_us as about_me, jobber.phone_number as phone_number, rate.rate as rate, rate.work as work_count, (rate.star1 + rate.star2 + rate.star3 + rate.star4 + rate.star5) as total_comments, request.id as "request.id" ,request.job_id as "request.job_id",request.status as "request.status",request.paid as "request.paid",EXTRACT(EPOCH FROM request.updated_at - ( NOW() - INTERVAL :user_pay_time))::INT as "request.remaining_time", request.updated_at + INTERVAL \'1 minute\' *  request.arrival_time as "request.arrival_time", request.time_base as "request.time_base", json_agg(services) as "request.services" From "Requests" as request INNER JOIN "Jobbers" as jobber on request.jobber_id = jobber.id LEFT OUTER JOIN "Rates" as rate on request.jobber_id = rate.jobber_id and rate.job_id = request.job_id INNER JOIN (SELECT S.title as title,rs.count as count, js.price as price,rs.price as total_price,rs.accepted as accepted,unit.title as unit,rs.request_id from "RequestServices" rs LEFT OUTER JOIN "JobberServices" js on js.id = rs.service_id LEFT OUTER JOIN "Services" S on js.service_id = S.id LEFT OUTER JOIN "Units" unit on js.unit_id = unit.id) as services on services.request_id = request.id WHERE  request.user_id = :user_id GROUP BY request.id, request.arrival_time, request.time_base,jobber.id,jobber.name,jobber.family, jobber.identifier, jobber.avatar, jobber.about_us, rate.rate , rate.work, rate.star1 , rate.star2 , rate.star3 , rate.star4 ,request.paid, rate.star5,request.job_id,request.status, request.updated_at ORDER BY request.created_at DESC LIMIT 1', {
                    replacements: {
                        user_id: req.user.id,
                        user_pay_time: `${process.env.USER_TIME_PAYING} minutes`
                    },
                    nest: true
                });
                if (requestPage.length > 0) {
                    const page = requestPage[0];

                    if (page.request.status === 'created' || page.request.status === 'canceled-by-jobber' || page.request.status === 'canceled-by-user' || page.request.status === 'done' || page.request.status === 'no-answer-busy' || page.request.status === 'no-answer-free') {
                        res.scaffold.failed(messages.notAnyRequestFound)
                    } else {
                        if (page.request.status !== "paid" && page.request.status !== "accepted") {
                            page.request.remaining_time = null;
                            page.request.arrival_time = null;
                        }
                        if (page.request.status === "created" || (page.request.status === "accepted" && page.request.time_base === false)) {
                            page.phone_number = null
                        }
                        page.comments = await sequelize.query('SELECT comments.id,sv.title as service_title, comments.comment as comment, comments.rate as rate FROM public."Comments" as comments LEFT OUTER JOIN public."Services" as sv ON comments.service_id = sv.id WHERE comments.jobber_id = :jobber_id AND comments.job_id = :job_id AND comments.comment <> \'\' AND comments.comment IS NOT NULL ORDER BY comments.id DESC LIMIT 3', {
                            replacements: {
                                job_id: page.request.job_id,
                                jobber_id: page.id,
                            },
                            nest: true
                        });
                        page.request.total_time_interval = null;
                        if (page.request.status === "finished") {
                            const timeInterval = await sequelize.query('SELECT date_part(\'hour\', finished.created_at - started.created_at) * 60 + date_part(\'minute\', finished.created_at - started.created_at) as total_time_interval FROM "RequestStatusReport" as finished CROSS JOIN "RequestStatusReport" as started where started.status = \'started\' AND started.request_id = :request_id AND finished.status = \'finished\' AND finished.request_id = :request_id',{
                                replacements: {
                                    request_id: page.request.id
                                },
                                plain: true,
                                nest: true
                            });
                            page.request.total_time_interval = timeInterval.total_time_interval
                        }

                        page.request.total_pay = (await getTotalPayableForRequestWithWallet(req.user.id,page.request.id));
                        page.request.user_time_paying = process.env.USER_TIME_PAYING * 60;
                        page.request.services.forEach(e => {
                            e.is_paid = e.accepted === true && page.request.paid === true
                        });
                        page.request.paid = undefined;
                        page.status = "online";
                        page.services = null;
                        page.distance = 0;
                        res.scaffold.add(page)
                    }
                }
                else {
                    res.scaffold.failed(messages.notAnyRequestFound)
                }
            }
            catch (e) {
                res.scaffold.failed(e.message)
            }
    },

    cancelLastRequest: async function (req,res) {
        let preStatus = '';
        const user_id = req.user.id;
        const request = await Request.findOne({
            where: {
                user_id: user_id
            },
            order: [['createdAt', 'DESC']]
        });
        if (request.status === 'accepted' ||
            request.status === 'created' ||
            (request.status === 'paid' && request.time_base === false)) {
            try {
                let canceledSuccess = true;
                if (request.status === 'paid')
                    canceledSuccess = await refundPayment(request.id);
                if (canceledSuccess) {
                    preStatus = request.status === 'created' ? 'canceled-by-user-prepay' : 'canceled-by-user';
                    request.status = 'canceled-by-user';
                    await request.save();
                    await JobberDailyStatus.destroy({
                        where: {
                            jobber_id: request.dataValues.jobber_id,
                            status: 'busy'
                        }
                    });
                    pushNotificationForRequest(request.id, req.user.device, preStatus)
                }
                res.scaffold.success()
            } catch (error) {
                res.scaffold.failed(error.message)
            }
        }
        else {
            res.scaffold.failed(messages.notAnyRequestFound)
        }
    },

    verifiedLastRequest: async function (req,res) {

    },

    payLastRequest: async function (req,res) {

    }
};
