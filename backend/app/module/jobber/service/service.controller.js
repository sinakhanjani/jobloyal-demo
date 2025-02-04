const {Service,Unit,JobberService,sequelize,JobberDailyStatus} = require('../../../../database/models');
const messages = require("../../../../helper/message.helper");
const Sequelize = require('sequelize');
const Op = Sequelize.Op;
const {getStepOfAuthorization} = require("../registration/jobber.register");

module.exports = {

    create : async function (req,res) {
        let userId = req.user.id;
        let stepAuth = {code: -1};
        if (userId === "ADMIN") {
            stepAuth.code = 3;
            userId = null
        }
        else {
            stepAuth = await getStepOfAuthorization(userId);
        }
        if (stepAuth.code === 3) {
            const {title, unit_id: unitId, job_id: jobId} = req.body;
            if (title) {
                Service.create({
                    title: title,
                    creator_user_id: userId,
                    default_unit_id: unitId,
                    job_id: jobId
                }).then(response => {
                    res.scaffold.add(response)
                }).catch(err => {
                    res.scaffold.failed(err.message)
                })
            } else {
                res.scaffold.failed(messages.parameterIsRequire)
            }
        }
        else {
            res.scaffold.failed(messages.jobberIsNotAuthorized)
        }
    },

    getAll : async function (req,res) {
        const {page, limit} = req.body;
        let count = null;
        if (page === 0) {
            count = await sequelize.query('SELECT COUNT(*) from public."Services"', {
                nest: true
            });
            count = parseInt(count[0].count)
        }
        const result = await sequelize.query('select service.*, row_to_json(unit.*) as unit from public."Services" as service left outer join public."Units" as unit on unit.id = service.default_unit_id limit :limit offset :page',
            {
                nest: true,
                replacements: {
                    page: (page || 0) * (limit || 10),
                    limit: limit || 10
                }
            });
        res.scaffold.add({"count" : count, items: result})
    },

    getAllInJobId: async function (req,res) {
        const {job_id:jobId} = req.body;
        if (jobId) {
            try {
                const services = await Service.findAll({
                    where: {job_id: jobId},
                    include: [{model: Unit, as:'unit'}]
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

    search: async function (req,res) {
        const {jobId:jobId,s} = req.body;
        if (jobId && s) {
            try {
                const services = await sequelize.query('SELECT "Service"."id" as "id","Service"."title" as "title", "Service"."default_unit_id",  "unit"."id" AS "unit.id", "unit"."title" AS "unit.title" FROM "Services" AS "Service" LEFT OUTER JOIN "Units" AS "unit" ON "Service"."default_unit_id" = "unit"."id"  WHERE (unaccent(\'unaccent\', "Service"."title") ILIKE :q OR "Service"."title" ILIKE :q) AND job_id = :job_id ORDER BY CASE WHEN unaccent(\'unaccent\', "Service"."title") ILIKE :q1 THEN 0 WHEN unaccent(\'unaccent\', "Service"."title") ILIKE :q2 THEN 1  WHEN unaccent(\'unaccent\', "Service"."title") ILIKE :q3 THEN 2  WHEN unaccent(\'unaccent\', "Service"."title") ILIKE :q4 THEN 3  ELSE 4 END, "Service"."title"',{
                    replacements: {search: s,q: `%${s}%`,q1:s,q2:`${s}%`,q3: `%${s}%`,q4: `%${s}`, job_id: jobId},
                    raw: true,
                    nest: true
                });
                services.forEach(e => {
                    if (!e.unit.id) e.unit = null
                })
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

    delete: async function (req,res) {
        const {id} = req.body;
        if (id) {
            Service.destroy({
                where:{id: id}
            }).then(response => {
                res.scaffold.success()
            }).catch(err => {
                res.scaffold.failed(err.message)
            })
        }
        else {
            res.scaffold.failed(messages.parameterIsRequire)
        }
    },

    addServiceToJobber: async function (req,res) {
        const {job_id:jobId,service_id:serviceId, unit_id: unitId,price} = req.body;
        if (jobId && serviceId && price) {
            const jobber_id = req.user.id;
            JobberService.findOrCreate({
                where: {
                    service_id: serviceId,
                    job_id : jobId,
                    jobber_id
                },
                defaults: {
                    job_id : jobId,
                    service_id: serviceId,
                    unit_id: unitId,
                    jobber_id,
                    price
                }
            }).then(response => {
                if (response[1] === true) {
                    res.scaffold.success()
                }
                else {
                    res.scaffold.failed(messages.serviceAlreadyAdded)
                }
            }).catch(err => {
                res.scaffold.failed(err.message)
            })
        }
        else {
            res.scaffold.failed(messages.parameterIsRequire)
        }

    },

    getAllServicesOfJobber: async function (req,res) {
        const jobber_id = req.user.id;
        if (jobber_id) {
            JobberService.findAll({
                where: {jobber_id}
            }).then(response => {
                res.scaffold.add({items: response})
            }).catch(err => {
                res.scaffold.failed(err.message)
            })
        }
        else {
            res.scaffold.failed(messages.parameterIsRequire)
        }
    },
    deleteServiceFromJobber: async function (req,res) {
        const {serviceId} = req.body;
        const jobber_id = req.user.id;
        if (serviceId) {
            const service = await JobberService.findOne({
                where: {
                    service_id: serviceId,
                    jobber_id
                }
            });
            JobberService.destroy({
                where: {service_id: serviceId, jobber_id}
            }).then(response => {
                JobberService.count({
                    where: {
                        job_id: service.job_id,
                        jobber_id: jobber_id
                    }
                }).then(response => {
                    if (response > 0) {
                        res.scaffold.success()
                    }
                    else {
                        JobberDailyStatus.create({
                            "status": "offline",
                            "jobber_id": jobber_id,
                            "job_id": service.job_id
                        }).then (e => {
                            res.scaffold.success()
                        });
                    }
                });

            }).catch(err => {
                res.scaffold.failed(err.message)
            })
        }
        else {
            res.scaffold.failed(messages.parameterIsRequire)
        }
    }
};
