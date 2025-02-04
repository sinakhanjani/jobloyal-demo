const {
    Request,
    RequestService,
    JobberService,
    JobberDailyStatus,
    Job, Service,
    sequelize, Jobber, JobberJob, Sequelize
} = require("../../../../database/models");
const {pushNotificationForRequest} = require("../../notification/notification.controller");
const {QueryTypes} = Sequelize;
const {Op} = require("sequelize");
const messages = require("../../../../helper/message.helper");
const {getLastLocationOfJobber} = require("../daily/jobber.location");
const {refundPayment} = require("../../payment/payment.controller");

 getLastAddedRequest = async function (jobber_id,region,onlyOne = false) {
    const lastLocation = await getLastLocationOfJobber(jobber_id);
    if (lastLocation) {
        const requests = await sequelize.query('SELECT req.id, jobs.title ->> :region as job_title, req.price as price, req.address as address,earth_distance(:earthLocation,req.location) as distance, EXTRACT(EPOCH FROM req.created_at - ( NOW() - INTERVAL :req_time_life)) as remaining_time, json_agg(r) AS services FROM public."Requests" as req LEFT OUTER JOIN (SELECT rservice."id" as id ,rservice.request_id,unit.title as unit ,rservice.price,rservice.count,"Services".title  from public."RequestServices" as rservice INNER JOIN (public."JobberServices" AS "Services->JobberServices" INNER JOIN public."Services" as "Services" ON "Services->JobberServices".service_id = "Services".id LEFT OUTER JOIN public."Units" as unit ON "Services->JobberServices".unit_id = unit.id)  ON "Services->JobberServices".id = rservice.service_id) as r ON r.request_id = req.id LEFT OUTER JOIN public."Jobs" as jobs ON req.job_id = jobs.id  WHERE req.jobber_id = :jobber_id AND req.status= \'created\' AND req.created_at >= NOW() - INTERVAL :req_time_life GROUP BY req.id,jobs.title' + (onlyOne === true ? ' LIMIT 1' : ''), {
            nest: true,
            type: QueryTypes.SELECT,
            replacements: {
                earthLocation: lastLocation.location,
                jobber_id: jobber_id,
                region: region,
                req_time_life: `${process.env.REQUEST_LIFE_TIME} minutes`
            }
        });
        return requests;
    }
    return null
};

module.exports = {
    getLastAddedRequest,
    getStatusOfLastRequest: async function (req, res) {
        const jobberId = req.user.id;
        try {
            const lastStatusOfJobber = await JobberDailyStatus.findOne({
                where: {
                    jobber_id: jobberId,
                }, order: [['created_at', 'DESC']]
            });
            if (lastStatusOfJobber === null || (lastStatusOfJobber != null && lastStatusOfJobber.status !== 'busy')) {
                res.scaffold.success()
            }
            else {
                const lastLocation = await getLastLocationOfJobber(jobberId);
                const requestPage = await sequelize.query('SELECT request.id, longitude(location),latitude(location),request.price as total,EXTRACT(EPOCH FROM request.updated_at - ( NOW() - INTERVAL :user_pay_time))::INT as remaining_time_to_pay,earth_distance(:earthLocation,request.location) as distance,request.address,request.job_id as job_id,request.status as status,request.updated_at + INTERVAL \'1 minute\' *  request.arrival_time as arrival_time, request.time_base, CONCAT("user".name,\' \',"user".family) as "user.name","user".phone_number as "user.phone" ,json_agg(services) as "services", request.updated_at From "Requests" as request INNER JOIN "Users" as "user" on request.user_id = "user".id INNER JOIN (SELECT S.title as title,rs.count as count, js.price as price,rs.price as total_price,rs.accepted as accepted,unit.title as unit,rs.request_id from "RequestServices" rs LEFT OUTER JOIN "JobberServices" js on js.id = rs.service_id LEFT OUTER JOIN "Services" S on js.service_id = S.id LEFT OUTER JOIN "Units" unit on js.unit_id = unit.id where rs.accepted = true) as services on services.request_id = request.id WHERE request.jobber_id = :jobber_id AND ((request.status = \'finished\' OR request.status = \'paid\' OR request.status = \'accepted\' OR request.status = \'arrived\' OR request.status = \'started\')) GROUP BY request.id, request.arrival_time, request.time_base,request.job_id,request.created_at,"user".id,"user".name,"user".family,"user".phone_number,request.status,request.address,request.location, request.price, request.updated_at ORDER BY request.created_at DESC LIMIT 1', {
                    replacements: {
                        jobber_id: jobberId,
                        earthLocation: lastLocation.location,
                        user_pay_time: `${process.env.USER_TIME_PAYING} minutes`
                    },
                    nest: true
                });
                if (requestPage.length > 0) {
                    const page = requestPage[0];
                    if (page.status === 'created' || page.status === 'cancel-by-user' || page.status === 'cancel-by-jobber' || page.status === 'done' || page.status === 'no-answer-busy' || page.status === 'no-answer-free') {
                        res.scaffold.add(`status : ${page.status}`)
                    } else {
                        page.user_time_paying= process.env.USER_TIME_PAYING * 60;
                        if (page.status === "finished") {
                            const timeInterval = await sequelize.query('SELECT date_part(\'hour\', finished.created_at - started.created_at) * 60 + date_part(\'minute\', finished.created_at - started.created_at) as total_time_interval FROM "RequestStatusReport" as finished CROSS JOIN "RequestStatusReport" as started where started.status = \'started\' AND started.request_id = :request_id AND finished.status = \'finished\' AND finished.request_id = :request_id',{
                                replacements: {
                                    request_id: page.id
                                },
                                plain: true,
                                nest: true
                            });
                            page.total_time_interval = timeInterval.total_time_interval
                        }

                        res.scaffold.add(page)
                    }
                } else {
                    res.scaffold.add("Zero")
                }
            }
        } catch (e) {
            res.scaffold.failed(e.message)
        }
    },

    getMyRequests: async function (req, res) {
        const jobber_id = req.user.id;
        const region = req.user.region;
        try {
            const requests = await getLastAddedRequest(jobber_id,region, false);
            res.scaffold.add({items: requests || [], request_life_time: process.env.REQUEST_LIFE_TIME * 60})
        } catch (e) {
            res.scaffold.failed(e.message)
        }
    },

    acceptRequest: async function (req, res) {
        const {request_id, accepted_services, arrival_time} = req.body;
        if (accepted_services && accepted_services.length > 0 && request_id && arrival_time) {
            const jobber_id = req.user.id;
            const today = new Date().toISOString().substring(0, 10);
            const request = await Request.findOne({
                where: {
                    jobber_id: jobber_id,
                    id: request_id,
                    status: 'created',
                    created_at: {[Op.gte]: new Date(Date.now() - 60000 * parseInt(process.env.REQUEST_LIFE_TIME))}
                }
            });
            if (request) {
                const checkJobberIsAvailable = await JobberDailyStatus.findOne({
                    where: {
                        jobber_id: jobber_id,
                        job_id: request.job_id,
                        created_at: {[Op.gte]: today}
                    },
                    order: [['id', 'DESC']]
                });
                if (checkJobberIsAvailable !== null && checkJobberIsAvailable.status === 'online') {
                    try {
                        const result = await sequelize.transaction(async (t) => {
                            await sequelize.query('insert into "JobberDailyStatus" (status,jobber_id,job_id,created_at) select \'busy\',jobber_id, job_id,NOW() from (select distinct on (ts.jobber_id,ts.job_id) ts.status,ts.jobber_id,ts.job_id,NOW() from "JobberDailyStatus" as ts where ts.jobber_id = :jobber_id order by ts.jobber_id,ts.job_id,id desc) as sq where sq.status = \'online\'', {
                                replacements: {jobber_id: jobber_id, today: today},
                                nest: true,
                                transaction: t
                            });
                            await Request.update({status: 'no-answer-busy'},
                                {
                                    where: {
                                        jobber_id: jobber_id,
                                        status: 'created',
                                        created_at: {[Op.gte]: new Date(Date.now() - 60000 * parseInt(process.env.REQUEST_LIFE_TIME))},
                                        id: {[Op.ne]: request_id}
                                    },
                                    transaction: t
                                });
                            request.status = 'accepted';
                            if (request.dataValues.time_base === false) {
                                const totalAcceptedPrice = await RequestService.findAll({
                                    attributes: [
                                        [sequelize.fn('sum', sequelize.col('price')), 'totalPrice'],
                                    ],
                                    where: {
                                        request_id: request_id,
                                        id: {[Op.in]: accepted_services}
                                    },
                                    plain: true
                                });
                                if (totalAcceptedPrice) {
                                    request.price = parseFloat(totalAcceptedPrice.dataValues.totalPrice);
                                }
                            }
                            request.arrival_time = parseInt(arrival_time);
                            await request.save({transaction: t});
                            await RequestService.update({accepted: true},
                                {
                                    where: {
                                        request_id: request_id,
                                        id: {[Op.in]: accepted_services}
                                    },
                                    transaction: t
                                })
                        });
                        res.scaffold.add({user_time_paying: process.env.USER_TIME_PAYING * 60})
                        pushNotificationForRequest(request_id,req.user.device)
                    } catch (error) {
                        res.scaffold.failed(error.message)
                    }
                } else {
                    res.scaffold.failed(messages.jobberNotAvailable)
                }
            } else {
                res.scaffold.failed(messages.notAnyRequestFound)
            }
        } else {
            res.scaffold.failed(messages.parameterIsRequire)
        }
    },

    rejectRequest: async function (req, res) {
        const jobber_id = req.user.id;
        const {request_id} = req.body;
        const request = await Request.findOne({
            where: {
                jobber_id: jobber_id,
                id: request_id
            }
        });
        if (request.dataValues.status === 'created') {
            request.status = 'rejected';
            try {
                await request.save();
                res.scaffold.success()
                pushNotificationForRequest(request_id,req.user.device)
            } catch (e) {
                res.scaffold.failed(e.message)
            }
        } else {
            res.scaffold.failed(messages.notAnyRequestFound)
        }
    },


    cancelLastRequest: async function (req,res) {
        const jobberId = req.user.id;
        const request = await Request.findOne({
            where: {
                jobber_id: jobberId,
                [Op.or] : [{[Op.and]: [{status: "accepted"}, {created_at: {[Op.lt]: new Date(Date.now() - 60000 * parseInt(process.env.USER_TIME_PAYING))}}, {time_base: false}]}, {[Op.and]: [{status: "accepted"}, {time_base: true}]},  {status: "arrived"}, {status: "started"}, {status: "finished"},{status: "paid"}]
            },
            order: [['createdAt', 'DESC']]
        });
        if (request) {
            if (request.status === 'accepted' || request.status === 'arrived' || request.status === 'started' || request.status === 'finished'  || request.status === 'paid') {
                try {
                    let canceledSuccess = true;
                    if (request.status !== 'accepted' && request.status === false) {
                        canceledSuccess = await refundPayment(request.id)
                    }
                    if (canceledSuccess) {
                        request.status = "canceled-by-jobber";
                        await request.save();
                        await JobberDailyStatus.destroy({
                            where: {
                                jobber_id: jobberId,
                                status: 'busy'
                            }
                        });
                    }
                    res.scaffold.success();
                    pushNotificationForRequest(request.id,req.user.device)
                } catch (error) {
                    res.scaffold.failed(error.message)
                }
            } else {
                res.scaffold.failed(messages.notAnyRequestFound)
            }
        }
        else {
            res.scaffold.failed(messages.notAnyRequestFound)
        }
    },

    getLocationOfRequest: async function (req, res) {
        const {request_id} = req.params;
        const jobber_id = req.user.id;
        try {
            const requestQ = await sequelize.query('select longitude(location),latitude(location),time_base,status,EXTRACT(EPOCH FROM created_at - (NOW() - INTERVAL :req_time_life)) as remaining_time from public."Requests" where id = :id and jobber_id = :jobber_id', {
                replacements: {
                    req_time_life: `${process.env.REQUEST_LIFE_TIME} minutes`,
                    jobber_id: jobber_id,
                    id: request_id
                },
                nest: true
            });
            const request = requestQ[0];
            if (request && request.status === 'created' && request.remaining_time > 0 || (request.status === 'accepted' || (request.time_base === false && request.status === 'paid'))) {
                res.scaffold.add({latitude: request.latitude, longitude: request.longitude})
            } else {
                res.scaffold.failed(messages.notAnyRequestFound)
            }
        } catch (e) {
            res.scaffold.failed(e.message)
        }
    },

    arriveJobber: async function (req, res) {
        const jobber_id = req.user.id;
        const request = await Request.update({status: 'arrived'}, {
            where: {
                jobber_id: jobber_id,
                [Op.or]: [{[Op.and]: [{time_base: false}, {status: 'paid'}]}, {[Op.and]: [{time_base: true}, {status: 'accepted'}]}]
            },
            limit: 1,
            returning:true
        });
        if (request[0] === 1) {
            res.scaffold.success();
            pushNotificationForRequest(request[1][0].id,req.user.device)
        } else {
            res.scaffold.failed(messages.notAnyRequestFound)
        }

    },
    startJob: async function (req, res) {
        const jobber_id = req.user.id;
        const request = await Request.update({status: 'started'}, {
            where: {
                jobber_id: jobber_id,
                status: 'arrived'
            },
            limit: 1,
            returning:true
        });
        if (request[0] === 1) {
            res.scaffold.success()
            pushNotificationForRequest(request[1][0].id,req.user.device)
        } else {
            res.scaffold.failed(messages.notAnyRequestFound)
        }

    },
    finishJob: async function (req, res) {
        const jobber_id = req.user.id;
        const request = await Request.findOne({
            where: {
                jobber_id: jobber_id,
                status: 'started'
            },
            order: [['created_at', 'desc']],
            limit: 1
        });
        if (request) {
            let reqUpdateStatus = [0];
            if (request.time_base === true) {
                const startedTime = await sequelize.query('select EXTRACT(EPOCH FROM NOW() - created_at) as working_time,created_at from public."RequestStatusReport" as requestStatusReport where request_id = :req_id and status = \'started\' limit 1', {
                    replacements: {
                        req_id: request.id
                    },
                    nest: true
                });
                if (startedTime.length > 0 && startedTime[0] !== null) {
                    const time = startedTime[0].working_time;
                    const workingTime = parseInt(time / 60);
                    let workTimeAsHour = workingTime/60;
                    if (workTimeAsHour < 1) workTimeAsHour = 1;
                    await RequestService.update({
                        count: workingTime,
                        price: sequelize.literal('price * ' + workTimeAsHour)
                    }, {
                        where: {
                            request_id: request.id,
                            count: 0
                        }
                    });
                    reqUpdateStatus = await Request.update({
                        status: 'finished',
                        price: sequelize.literal('price * ' + workTimeAsHour)
                    }, {
                        where: {
                            jobber_id: jobber_id,
                            status: 'started'
                        },
                        limit: 1
                    });
                }
            }
            else {
                reqUpdateStatus = await Request.update({
                    status: 'finished'
                }, {
                    where: {
                        jobber_id: jobber_id,
                        status: 'started'
                    },
                    limit: 1
                });
            }

            if (reqUpdateStatus[0] === 1) {
                res.scaffold.success();
                pushNotificationForRequest(request.id,req.user.device)
            } else {
                res.scaffold.failed(messages.notAnyRequestFound)
            }
        } else {
            res.scaffold.failed(messages.notAnyRequestFound)
        }
    }

};
