const {sequelize} = require("../../../../database/models")

module.exports = {
    getComments: async function (req,res) {
        const jobber_id = req.user.id;
        const {job_id,page,limit} = req.body
        if (job_id) {
            try {
                const comments = await sequelize.query('SELECT comments.id,sv.title as service_title, comments.comment as comment, comments.rate as rate FROM public."Comments" as comments LEFT OUTER JOIN public."Services" as sv ON comments.service_id = sv.id WHERE comments.jobber_id = :jobber_id AND comments.job_id = :job_id AND comments.comment is not null AND comments.comment != \'\' ORDER BY comments.id DESC LIMIT :limit OFFSET :page',{
                    replacements: {
                        job_id: job_id,
                        jobber_id: jobber_id,
                        page: (page || 0) * (limit || 10),
                        limit: limit || 10
                    },
                    nest: true
                })
                res.scaffold.add({items: comments})
            }
            catch (e) {
                res.scaffold.failed(e.message)
            }
        }
        else {
            res.scaffold.failed(messages.parameterIsRequire)
        }
    }
}
