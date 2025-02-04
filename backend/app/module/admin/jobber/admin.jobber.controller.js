const {getStepOfAuthorization} = require ("../../jobber/registration/jobber.register");
const {Jobber,sequelize,JobberDailyStatus,Request,JobberLocation,Rate,JobberStatic} = require("../../../../database/models");
const Sequelize = require("sequelize");
const Op = Sequelize.Op;
const IBAN = require('');
const messages = require("../../../../helper/message.helper");

module.exports = {

    getAll: async function (req,res) {
        const {page, limit} = req.body;
        let userCount = null;
        if (page === 0) {
            userCount = await sequelize.query('SELECT COUNT(*) from public."Jobbers" where deleted_at is null ', {
                nest: true
            });
            userCount = parseInt(userCount[0].count)
        }
        const users = await sequelize.query('select "Jobbers".*,su.finite,su.expired from public."Jobbers" as "Jobbers" left outer join public."SuspendUsers" as su on su.user_id = "Jobbers".id where deleted_at is null order by "Jobbers".created_at DESC limit :limit offset :page',
            {
                nest: true,
                replacements: {
                    page: (page || 0) * (limit || 10),
                    limit: limit || 10
                }
            });
        res.scaffold.add({"count" : userCount, items: users})
    },
    searchJobber: async function (req,res) {
        const {page, limit,s} = req.body;
        let search = s.replace(" ","%");
        let userCount = null;
        if (page === 0) {
            userCount = await sequelize.query('SELECT COUNT(*) from public."Jobbers" as "user" left outer join public."SuspendUsers" as su on su.user_id = "user".id where "user".name ilike :s or "user".family ilike :s or "user".phone_number like :s or concat("user".name,"user".family) ilike :s or "user".identifier ilike :s', {
                nest: true,
                replacements: {
                    s: `%${search}%`
                }
            });
            userCount = parseInt(userCount[0].count)
        }
        const users = await sequelize.query('select "user".*,su.finite,su.expired from public."Jobbers" as "user" left outer join public."SuspendUsers" as su on su.user_id = "user".id where "user".name ilike :s or "user".family ilike :s or "user".phone_number like :s or concat("user".name,"user".family) ilike :s or "user".identifier ilike :s  order by "user".created_at limit :limit offset :page',
            {
                nest: true,
                replacements: {
                    page: (page || 0) * (limit || 10),
                    limit: limit || 10,
                    s: `%${search}%`
                }
            });
        res.scaffold.add({"count" : userCount, items: users})
    },

    getJobberById : async function (req,res) {
        const jobber_id = req.params.id;
        const jobber = await Jobber.findOne({where: {id: jobber_id}, plain: true, paranoid: false});
        let response = {...jobber.dataValues};
        const lastAcceptedRequest = await Request.findOne({
            where: {
                jobber_id: jobber_id,
                status: {[Op.ne]: 'created'}
            },
            attributes: ['id'],
            order: [['created_at','DESC']]
        });
        response["lastAcceptedRequestId"] = lastAcceptedRequest ? lastAcceptedRequest.id : null;

        const lastRequest = await Request.findOne({
            where: {
                jobber_id: jobber_id
            },
            attributes: ['id'],
            order: [['created_at','DESC']]
        });
        response["lastRequestId"] = lastRequest ? lastRequest.id : null;

        const location = await JobberLocation.findOne({
            where: {
                jobber_id: jobber_id
            },
            attributes: ['address','created_at'],
            order: [['created_at','DESC']]
        });
        response["location"] = location;




        /// Generate Reports And Tags
        const doneRequestCount = await sequelize.query('select COUNT(*) from public."Requests" as req where req.jobber_id = :id and (req.status = \'verified\' or req.status = \'done\' or req.status = \'deposited\')',
            {
                replacements: {
                    id: jobber_id
                },
                nest: true
            });
        const acceptedRequestCountQuery = await sequelize.query('select COUNT(*) from public."Requests" as req where req.jobber_id = :id and req.status != \'created\'',
            {
                replacements: {
                    id: jobber_id
                },
                nest: true
            });
        const totalRequestCountQuery = await sequelize.query('select COUNT(*) from public."Requests" as req where req.jobber_id = :id',
            {
                replacements: {
                    id: jobber_id
                },
                nest: true
            });
        const totalIncomeQuery = await sequelize.query('select SUM(price) as total from public."Requests" as request where request.jobber_id = :jobber_id and (request.status = \'deposited\' or request.status = \'done\' or request.status = \'verified\' or request.status = \'paid\')',
            {
                replacements: {
                    jobber_id: jobber_id
                },
                nest: true
            });
        const creditQuery = await sequelize.query('SELECT SUM(price) as total FROM public."Requests" WHERE jobber_id = :jobber_id AND (status = \'done\' OR status = \'verified\') AND paid = true AND deposit_id is null ;', {
            replacements: {
                jobber_id: jobber_id
            },
            nest: true
        });
        const credit = creditQuery.length > 0 && creditQuery[0] ? parseFloat(creditQuery[0].total || 0) : 0;
        const statusOfAuthentication = await getStepOfAuthorization(jobber_id,jobber);
        const totalIncome = totalIncomeQuery.length > 0 ? totalIncomeQuery[0].hasOwnProperty("total") ? totalIncomeQuery[0].total : 0 : 0;
        const doneRequestsCount = (doneRequestCount.length > 0 && doneRequestCount[0].hasOwnProperty("count")) ? parseInt(doneRequestCount[0].count) : 0;
        const acceptedRequestCount = (acceptedRequestCountQuery.length > 0 && acceptedRequestCountQuery[0].hasOwnProperty("count")) ? parseInt(acceptedRequestCountQuery[0].count) : 0;
        const totalRequestCount = (totalRequestCountQuery.length > 0 && totalRequestCountQuery[0].hasOwnProperty("count")) ? parseInt(totalRequestCountQuery[0].count) : 0;

        const tags = [
            {
                title: "Total Requests",
                value: totalRequestCount
            },
            {
                title: "Accepted Requests",
                value: (((acceptedRequestCount || 0) * 100)/(totalRequestCount || 1)).toFixed(0) + '%'
            },
            {
                title: "Done Work/Accept",
                value: (((doneRequestsCount || 0) * 100)/(acceptedRequestCount || 1)).toFixed(0) + '%'
            },
            {
                title: "Authorized",
                value: statusOfAuthentication.code === 3 ? "YES" : statusOfAuthentication.code === 2 ? "PFC" : "NO"
            },
            {
                title: "Credit",
                value: credit + " CHF"
            },
            {
                primary: true,
                title: "Total Income",
                value: totalIncome,
                subvalue: "CHF"
            }
        ];
        response["tags"] = tags;


        ////Rating Fetch
        const rate = await Rate.findOne({
            where: {
                jobber_id: jobber_id
            },
            attributes: ['rate','work'],
            order: [['rate','DESC']]
        });
        response["rate"] = rate ? rate.rate : null;
        response["total_comment"] = rate ? rate.work : null;

        //Iban AND PERIOD
        const statics = await JobberStatic.findOne({where: {jobber_id: jobber_id},plain: true});
        response["statics"] = statics;


        /// JOBS AND SERVICES
        const today = new Date();
        const todayAsString = today.toISOString().substring(0, 10);
        const jobs = await sequelize.query('SELECT "JobberJob"."job_id", "JobberJob"."enabled", "job"."title" ->> \'en\' AS "title", json_agg("services") as "services",jobberStatus.status as status, jobberStatus.created_at as status_created_time FROM "JobberJobs" AS "JobberJob" LEFT OUTER JOIN "Jobs" AS "job" ON "JobberJob"."job_id" = "job"."id" LEFT OUTER JOIN (SELECT serv.title as "service_title", unit.title as "unit_title", js.price as price, js.service_id as id, js.deleted_at as "deletedAt",js.job_id from public."JobberServices" as js left outer join public."Services" as serv on js.service_id = serv.id LEFT OUTER JOIN public."Units" as unit ON js.unit_id = unit.id WHERE js.jobber_id = :jobber_id ) as services ON services.job_id = "JobberJob"."job_id"  LEFT OUTER JOIN (select DISTINCT ON (job_id) status, created_at,job_id from public."JobberDailyStatus" as jobberStatus WHERE jobber_id = :jobber_id AND created_at >= date :today ORDER BY job_id, jobberStatus.created_at DESC) as jobberStatus ON "JobberJob"."job_id" = jobberStatus.job_id  WHERE "JobberJob"."jobber_id" = :jobber_id group by "JobberJob".job_id, "JobberJob"."enabled", "job"."title", jobberStatus.status, jobberStatus.created_at',
            {
                replacements: {
                    jobber_id: jobber_id,
                    today: todayAsString
                },
                raw: true,
                nest: true
            });
        response["jobs"] = jobs;

        //SUSPEND
        const suspend = await sequelize.query('select id,reason,finite,expired from public."SuspendUsers" as su where su.user_id = :id and ((su.finite = true and su.expired > NOW()) or (su.finite = false)) limit 1',
            {
                replacements: {
                    id: jobber_id
                },
                plain: true
            });
        response["suspend"] = suspend;


        res.scaffold.add(response)
    },

    editIban : async (req,res) => {
        const {iban, period, jobber_id} = req.body;
        try {
            if (IBAN.isValid(iban)) {
                const result = await JobberStatic.update({
                    card_number: iban.replace(/\s+/g,""),
                    pony_period: period
                }, {
                    where: {
                        jobber_id: jobber_id
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
    }
};
