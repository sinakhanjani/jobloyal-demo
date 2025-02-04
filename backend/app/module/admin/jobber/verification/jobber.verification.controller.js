const {JobberDocument, sequelize, Jobber} = require("../../../../../database/models");
const {pushNotificationForJobberAuthorize} = require("../../../notification/notification.controller");
const {QueryTypes} = require('sequelize');

function isUUID ( uuid ) {
    let s = "" + uuid;
    s = s.match('^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
    if (s === null) {
        return false;
    }
    return true;
}

module.exports = {

    getJobberDocument: async (req, res) => {
        const id = req.params.id;
        try {
            const result = await JobberDocument.findAll({
                where: {
                    jobber_id: id
                }
            });
            res.scaffold.add(result)
        } catch (e) {
            res.scaffold.failed(e.message)
        }
    },

    getJobbersPendingDocument: async (req, res) => {
        try {
            const count = await sequelize.query('SELECT count(*) AS "count" FROM "JobberDocuments" AS "JobberDocument" WHERE "JobberDocument"."accepted" IS NULL', {plain: true});
            const items = await sequelize.query('SELECT "JobberDocument"."id", "JobberDocument"."jobber_id", "JobberDocument"."doc_url", concat("Jobber"."name", \' \', "Jobber"."family") as "name", "JobberDocument"."accepted", "JobberDocument"."created_at" AS "createdAt", "JobberDocument"."updated_at" AS "updatedAt" FROM "JobberDocuments" AS "JobberDocument" LEFT OUTER JOIN "Jobbers" AS "Jobber" ON "Jobber".id = "JobberDocument"."jobber_id" WHERE "JobberDocument"."accepted" IS NULL ORDER BY "JobberDocument"."created_at" DESC',
                {
                    type: QueryTypes.SELECT
                });
            res.scaffold.add({count: parseInt(count.count), items: items})
        } catch (e) {
            res.scaffold.failed(e.message)
        }
    },
    searchDocuments : async (req,res) => {
        const {s,page,limit} = req.body;
        let whereCondition = "";
        if (s === "all") {

        }
        else if(isUUID(s)) {
            whereCondition = ' WHERE "JobberDocument"."jobber_id" = :s '
        }
        try {
            const count = await sequelize.query('SELECT count(*) AS "count" FROM "JobberDocuments" AS "JobberDocument"' + whereCondition, {plain: true,
                replacements: {
                    s: s
                }
            });
            const items = await sequelize.query('SELECT "JobberDocument"."id", "JobberDocument"."jobber_id", "JobberDocument"."doc_url", concat("Jobber"."name", \' \', "Jobber"."family") as "name", "JobberDocument"."accepted", "JobberDocument"."created_at" AS "createdAt", "JobberDocument"."updated_at" AS "updatedAt" FROM "JobberDocuments" AS "JobberDocument" LEFT OUTER JOIN "Jobbers" AS "Jobber" ON "Jobber".id = "JobberDocument"."jobber_id"' + whereCondition + ' ORDER BY "JobberDocument"."created_at" DESC limit :limit offset :page',
                {
                    type: QueryTypes.SELECT,
                    replacements: {
                        s: s,
                        page: (page || 0) * (limit || 10),
                        limit: limit || 10,
                    },
                });
            res.scaffold.add({count: parseInt(count.count), items: items})
        } catch (e) {
            res.scaffold.failed(e.message)
        }
    },

    acceptJobber: async (req, res) => {
        const jobberId = req.body.jobber_id;
        try {
            const result = await JobberDocument.update({accepted: true}, {
                where: {
                    jobber_id: jobberId
                }
            });
            await Jobber.update({authorized: true}, {
                where: {
                    id: jobberId
                }
            });
            res.scaffold.success();
            pushNotificationForJobberAuthorize(req.user.id, 'accept-document')
        } catch (e) {
            res.scaffold.failed(e.message)
        }
    },
    rejectJobber: async (req, res) => {
        const jobberId = req.body.jobber_id;
        try {
            const result = await JobberDocument.update({accepted: false}, {
                where: {
                    jobber_id: jobberId
                }
            });
            res.scaffold.success();
            pushNotificationForJobberAuthorize(req.user.id, 'reject-document')
        } catch (e) {
            res.scaffold.failed(e.message)
        }
    }
};
