const {JobberJob} = require("../../../../database/models");
const {Job} = require("../../../../database/models");
const {Jobber, sequelize} = require("../../../../database/models");
const messages = require("../../../../helper/message.helper");


module.exports = {

    add: async function (req, res) {
        const jobId = req.body.job_id;
        if (jobId) {
            JobberJob.findOrCreate({
                where: {
                    jobber_id: req.user.id,
                    job_id: jobId
                }
            }).then(response => {
                res.scaffold.add(response[0])
            }).catch(reason => {
                res.scaffold.failed(reason.message)
            })
        } else {
            res.scaffold.failed(messages.parameterIsRequire)
        }
    },

    getAllJobs: async function (req, res) {
        const jobber_id = req.user.id;
        const region = req.user.region;
        const today = new Date();
        const todayAsString = today.toISOString().substring(0, 10);

        const jobs = await sequelize.query('SELECT "JobberJob"."job_id", "JobberJob"."enabled", "job"."title" ->> :region AS "title", "count_service"."count" as "service_conut",jobberStatus.status as status, jobberStatus.created_at as status_created_time FROM "JobberJobs" AS "JobberJob" LEFT OUTER JOIN "Jobs" AS "job" ON "JobberJob"."job_id" = "job"."id" LEFT OUTER JOIN (SELECT COUNT (job_id), js.job_id  from public."JobberServices" as js WHERE js.jobber_id = :jobber_id and js.deleted_at is null GROUP BY js.job_id) as count_service ON count_service.job_id = "JobberJob"."job_id"  LEFT OUTER JOIN (select DISTINCT ON (job_id) status, created_at,job_id from public."JobberDailyStatus" as jobberStatus WHERE jobber_id = :jobber_id AND created_at >= date :today ORDER BY job_id, jobberStatus.created_at DESC) as jobberStatus ON "JobberJob"."job_id" = jobberStatus.job_id  WHERE "JobberJob"."jobber_id" = :jobber_id AND "JobberJob".deleted_at is null',
            {
                replacements: {
                    jobber_id: jobber_id,
                    region: region,
                    today: todayAsString
                },
                nest: true
            });
        res.scaffold.add({items: jobs})
    },

    getJobPage: async function (req, res) {
        const jobber_id = req.user.id;
        const {job_id} = req.body;
        let jobPage = await sequelize.query('SELECT CAST(request_count.count as INT) as request_count,(rate.star1 + rate.star2 + rate.star3 + rate.star4 + rate.star5) as total_comments,rate.work as work_count, rate.rate as rate,json_agg(jobberService) as services from public."JobberJobs" as jobberJobs LEFT OUTER JOIN public."Rates" as rate on rate.jobber_id = jobberJobs.jobber_id and rate.job_id = :job_id LEFT OUTER JOIN (select services.id , services.title as title,jobberService.price as price, unit.unit_title as unit from public."JobberServices" as jobberService LEFT OUTER JOIN (select id,title from public."Services") as services ON jobberService.service_id = services.id LEFT OUTER JOIN (select title as unit_title,id from public."Units") as unit on unit.id = jobberService.unit_id where jobberService.jobber_id = :jobber_id and jobberService.job_id = :job_id and jobberService.deleted_at is null ) as jobberService on 1 = 1 LEFT OUTER JOIN (select count(id) from public."Requests" as req where req.jobber_id = :jobber_id and req.job_id = :job_id) as request_count on 1 = 1 where jobberJobs.jobber_id = :jobber_id and jobberJobs.job_id = :job_id and jobberJobs.deleted_at is null GROUP BY rate.star1, rate.star2, rate.star3, rate.star4, rate.star5,rate.work,rate.rate, request_count.count',
            {
                replacements: {
                    jobber_id: jobber_id,
                    job_id: job_id
                },
                nest: true
            });
        if (jobPage.length > 0) {
            jobPage = jobPage[0];
            if (jobPage.services.length <= 0 || (jobPage.services.length === 1 && jobPage.services[0] === null)) {
                jobPage.services = null
            }
            jobPage.total_income = "0.00";
            const req = await sequelize.query('SELECT SUM(price) as total FROM public."Requests" WHERE jobber_id = :jobber_id AND (status = \'deposited\' OR status = \'done\' OR status = \'verified\') AND paid = true AND job_id = :job_id;', {
                replacements: {
                    jobber_id: jobber_id,
                    job_id: job_id
                },
                nest: true
            });
            if (req.length > 0 && req[0]  && req[0].total != null)
                jobPage.total_income = parseFloat(req[0].total).toFixed(2);
            res.scaffold.add(jobPage)
        }
        else {
            res.scaffold.success()
        }
    },

    delete: async function (req, res) {
        const jobId = req.body.job_id;
        const jobberId = req.user.id;
        if (jobId) {
            JobberJob.destroy({
                where: {jobber_id: jobberId, job_id: jobId}
            }).then(response => {
                res.scaffold.success()
            }).catch(err => {
                res.scaffold.failed(err.message)
            })
        } else {
            res.scaffold.failed(messages.parameterIsRequire)
        }
    }
};
