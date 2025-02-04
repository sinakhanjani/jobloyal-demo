const {Service,Unit,JobberService,sequelize} = require('../../../../database/models')
const messages = require("../../../../helper/message.helper")
const Sequelize = require('sequelize');
const Op = Sequelize.Op;

module.exports = {
    search: async function (req,res) {
        const region = req.user.region;
        const {s} = req.body;
        if (s) {
            try {
                const services = await sequelize.query('SELECT "Service"."id" as "service_id","Jobs"."id" as "job_id","Jobs"."title" -> :region as "job_title","Service"."title" as "service_title", "Categories"."title" -> :region as "category_title"  FROM "Services" AS "Service" LEFT OUTER JOIN ("Jobs" AS "Jobs" LEFT OUTER JOIN "Categories" ON "Categories"."id" = "Jobs"."category_id") ON "Jobs"."id" = "Service"."job_id" WHERE unaccent(\'unaccent\', "Service"."title") ILIKE :q OR "Service"."title" ILIKE :q ORDER BY CASE WHEN "Service"."title" ILIKE :q1 THEN 0 WHEN "Service"."title" ILIKE :q2 THEN 1  WHEN "Service"."title" ILIKE :q3 THEN 2  WHEN "Service"."title" ILIKE   :q4 THEN 3  ELSE 4 END, "Service"."title"',{
                    replacements: {search: s,q: `%${s}%`,q1:s,q2:`${s}%`,q3: `%${s}%`,q4: `%${s}`,region: region},
                    raw: true,
                    nest: true
                });
                res.scaffold.add({items: services})
            }
            catch (e) {
                res.scaffold.failed(e.message)
            }
        }
        else {
            res.scaffold.failed(messages.parameterIsRequire)
        }
    },

    listOfReservedServices: async function (req,res) {
        const user_id = req.user.id;
        const {page, limit} = req.body;
        const services = await sequelize.query('select req.id as id,s.title as title,reqServices.count as count, reqServices.price as price, concat(jobber.name,\' \', jobber.family) as jobber_name,unit.title as unit,reqServices.created_at as reserved_at  from public."RequestServices" as reqServices LEFT OUTER JOIN  public."Requests" as req on reqServices.request_id = req.id LEFT OUTER JOIN public."JobberServices" as js on js.id = reqServices.service_id LEFT OUTER JOIN public."Services" as s on s.id = js.service_id LEFT OUTER JOIN public."Units" as unit on unit.id = js.unit_id LEFT OUTER JOIN public."Jobbers" as jobber on jobber.id = req.jobber_id where req.user_id = :user_id AND req.status = \'done\' limit :limit offset :page',{
            replacements: {
                user_id: user_id,
                page: (page || 0) * (limit || 10),
                limit: limit || 10
            },
            nest: true
        });
        services.forEach(e => {
            e.price = ((parseInt((e.price * 100).toFixed()) * (1 + (process.env.COMMISSION / 100))) / 100).toFixed(2);
        });
        res.scaffold.add({items: services})
    },

    listOfCanceledServices: async function (req,res) {
        const user_id = req.user.id;
        const {page, limit} = req.body;
        const services = await sequelize.query('select req.id as id,s.title as title,reqServices.count as count, reqServices.price as price, concat(jobber.name,\' \', jobber.family) as jobber_name,unit.title as unit,reqServices.created_at as reserved_at,req.status as status  from public."RequestServices" as reqServices LEFT OUTER JOIN  public."Requests" as req on reqServices.request_id = req.id LEFT OUTER JOIN public."JobberServices" as js on js.id = reqServices.service_id LEFT OUTER JOIN public."Services" as s on s.id = js.service_id LEFT OUTER JOIN public."Units" as unit on unit.id = js.unit_id LEFT OUTER JOIN public."Jobbers" as jobber on jobber.id = req.jobber_id where req.user_id = :user_id AND (req.status = \'canceled-by-user\' OR req.status = \'canceled-by-jobber\' OR req.status = \'no-answer-busy\' OR req.status = \'no-answer-free\' OR (req.status = \'created\' AND req.created_at < NOW() - INTERVAL :req_time_life)) limit :limit offset :page',{
            replacements: {
                user_id: user_id,
                page: (page || 0) * (limit || 10),
                limit: limit || 10,
                req_time_life: `${process.env.REQUEST_LIFE_TIME} minutes`
            },
            nest: true
        });
        services.forEach(e => {
            e.price = ((parseInt((e.price * 100).toFixed()) * (1 + (process.env.COMMISSION / 100))) / 100).toFixed(2);
            e.cancled_by = e.status === "canceled-by-user" ? "you" : "jobber"
        });
        res.scaffold.add({items: services})
    }
};
