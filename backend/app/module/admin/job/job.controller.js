const {Job,sequelize} = require("../../../../database/models");
const messages = require("../../../../helper/message.helper");

setRegionToTitle = function (jobs,req) {
    const region = req.user.region;
    console.log(region);
    if (region) {
        for (const job of jobs) {
            job.title = job.title[region]
        }
        return jobs
    }
    else {
        return jobs
    }
};
module.exports = {
    create : async function (req,res) {
        const {title_fr,title_en,category_id} = req.body;
        try {
            const job = await Job.create({
                title: {fr:title_fr,en:title_en},
                category_id: category_id
            });
            res.scaffold.add(job)
        }
        catch (e) {
            res.scaffold.failed(e)
        }res.scaffold.failed(e)
    },
    getAll : async function (req,res) {
        const {page, limit} = req.body;
        let count = null;
        if (page === 0) {
            count = await sequelize.query('SELECT COUNT(*) from public."Jobs"', {
                nest: true
            });
            count = parseInt(count[0].count)
        }
        const result = await sequelize.query('select * from public."Jobs" limit :limit offset :page',
            {
                nest: true,
                replacements: {
                    page: (page || 0) * (limit || 10),
                    limit: limit || 10
                }
            });
        res.scaffold.add({"count" : count, items: result})
    },
    getAllJobInCategory : async function (req,res) {
        const {category_id} = req.body;
        try {
            const jobs = await Job.findAll({where: {
                category_id: category_id
                }});
            if (jobs.length > 0) {
                res.scaffold.add({items: setRegionToTitle(jobs,req)})
            }
            else {
                res.scaffold.add(null)
            }
        }
        catch (e) {
            res.scaffold.failed(e)
        }
    },

    delete: async function(req,res) {
        const {job_id} = req.body;
        try {
            const result = await Job.destroy({where: {
                id: job_id
                }});
            res.scaffold.add(result)
        } catch (e) {
            res.scaffold.failed(e)
        }
    },

    editJobTitle: async function (req,res) {
        const {title_fr,title_en,id} = req.body;
        if (title_fr && title_en && id) {
            try {
                const job = await Job.update({
                        title: {
                            fr: title_fr,
                            en: title_en
                        }
                    }, {
                        where: {
                            id: id
                        }
                    });
                if (job.length > 0 && job[0] === 1) {
                    res.scaffold.add({id,title_ch: title_fr,title_fr,title_en})
                }
                else {
                    res.scaffold.failed(messages.badUpdate)
                }
            } catch (e) {
                res.scaffold.failed(e)
            }
        }
        else {
            res.scaffold.failed(messages.parameterIsRequire)
        }
    }
};
