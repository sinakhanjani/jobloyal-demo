const messages = require('../../../../helper/message.helper');
const {Request,sequelize,Deposit} = require('../../../../database/models')

module.exports = {

    getReports : async (req, res) => {
        const jobberId = req.user.id;
        const {page, limit} = req.body;
        const region = req.user.region;
        const reports = await sequelize.query('SELECT req.id,jobs.title ->> :region as job_title ,req.status as status, req.created_at as created_at, req.address as address FROM public."Requests" as req LEFT OUTER JOIN public."Jobs" as jobs ON jobs.id = job_id WHERE jobber_id = :jobber_id AND (status != \'created\' OR (status = \'created\' AND req.created_at < (NOW() - interval :life_time_request))) ORDER BY req.created_at DESC LIMIT :limit OFFSET :offset', {
            replacements: {
                region: region,
                jobber_id: jobberId,
                limit: limit || 10,
                offset: (page || 0) * (limit || 10),
                life_time_request: `${process.env.REQUEST_LIFE_TIME} minutes`
            },
            nest: true
        });
        reports.forEach(e => {
            if (e.status === "created" || e.status === "no-answer-busy" || e.status === "no-answer-free" || e.status === "rejected") {
                e.tag = "rejected"
            }
            else if (e.status === "canceled-by-user" || e.status === "canceled-by-jobber"){
                e.tag = "canceled"
            }
            else {
                e.tag = "accepted"
            }
        });
        res.scaffold.add({items: reports})
    },
    getServicesOfRequest : async (req,res) => {
        const {id} = req.params;
        const jobberId = req.user.id;
        const requestPage = await sequelize.query('SELECT request.id,request.status as status, request.created_at as created_at, request.address as address, json_agg(services) as "services" From "Requests" as request LEFT OUTER JOIN (SELECT S.title as title,rs.count as count, js.price as price,rs.price as total_price,rs.accepted as accepted,unit.title as unit,rs.request_id from "RequestServices" rs LEFT OUTER JOIN "JobberServices" js on js.id = rs.service_id LEFT OUTER JOIN "Services" S on js.service_id = S.id LEFT OUTER JOIN "Units" unit on js.unit_id = unit.id) as services on services.request_id = request.id WHERE request.jobber_id = :jobber_id AND request.id = :request_id GROUP BY request.id,request.status, request.created_at, request.address LIMIT 1', {
            replacements: {
                jobber_id: jobberId,
                request_id: id,
            },
            nest: true
        });
        if (requestPage && requestPage.length > 0 && requestPage[0] != null) {
            res.scaffold.add(requestPage[0])
        }
        else {
            res.scaffold.success()
        }
    },

    getTurnover : async (req,res) => {
        const jobberId = req.user.id;
        try {
            const deposit = await Deposit.findAll({
                where: {
                    jobber_id: jobberId
                },
                order: [['created_at','desc']]
            });
            res.scaffold.add({items: deposit})
        }
        catch (e) {
            res.scaffold.failed(e)
        }
    }

};
