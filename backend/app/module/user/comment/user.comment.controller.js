const {Request,RequestService,JobberService,Comment,Rate,sequelize} = require("../../../../database/models");
const messages = require("../../../../helper/message.helper");
const {
    score,
    rate,
    average
} = require('average-rating');

module.exports = {
    submit : async function (req,res) {
        const userId = req.user.id;
        const {comment,rate} = req.body;
        if (rate <= 5 && rate >= 1) {
            try {
                const lastRequest = await Request.findOne({
                    where: {
                        user_id: userId
                    },
                    attributes: ['id', 'created_at', 'status', 'jobber_id', 'job_id'],
                    order: [['created_at', 'DESC']]
                });
                if (lastRequest && lastRequest.status === 'verified') {
                    const service = await RequestService.findOne({
                        where: {request_id: lastRequest.id},
                        order: [['id', 'DESC']],
                        include: {model: JobberService, attributes: ['service_id']}
                    });
                    const commentResponse = await Comment.build({
                        jobber_id: lastRequest.jobber_id,
                        job_id: lastRequest.job_id,
                        service_id: service.JobberService.service_id,
                        request_id: lastRequest.id,
                        comment: comment,
                        rate: rate
                    });
                    const rateCondition = {
                        jobber_id: lastRequest.jobber_id,
                        job_id: lastRequest.job_id,
                    };
                    let rateSystem = await Rate.findOne({where: rateCondition});
                    if (rateSystem) {
                        rateSystem[`star${rate}`] = rateSystem[`star${rate}`] + 1;
                        // rateSystem['work'] = rateSystem['work'] + 1; it's plus on verify step
                        rateSystem.rate = average([rateSystem.star1, rateSystem.star2, rateSystem.star3, rateSystem.star4, rateSystem.star5]);
                        await rateSystem.save()
                    }
                    // sure it's created at verify step
                    // else {
                    //     const newRateBar = {[`star${rate}`]: 1, ...rateCondition};
                    //     newRateBar.rate = rate;
                    //     rateSystem = await Rate.create(newRateBar)
                    // }
                    lastRequest.status = 'done';
                    await lastRequest.save();
                    await commentResponse.save();
                    res.scaffold.add(rateSystem)
                } else {
                    res.scaffold.failed(messages.notAnyRequestFound)
                }
            }
            catch (e) {
                res.scaffold.failed(e.message)
            }
        }
        else {
            res.scaffold.failed(messages.parameterIsRequire)
        }
    },

    getComments: async function (req,res) {
        const {jobber_id, job_id,page,limit} = req.body;
        if (jobber_id && job_id) {
            try {
                const comments = await sequelize.query('SELECT comments.id,sv.title as service_title, comments.comment as comment, comments.rate as rate FROM public."Comments" as comments LEFT OUTER JOIN public."Services" as sv ON comments.service_id = sv.id WHERE comments.jobber_id = :jobber_id AND comments.job_id = :job_id AND comments.comment is not null AND comments.comment != \'\' ORDER BY comments.id DESC LIMIT :limit OFFSET :page',{
                    replacements: {
                        job_id: job_id,
                        jobber_id: jobber_id,
                        page: (page || 0) * (limit || 10),
                        limit: limit || 10
                    },
                    nest: true
                });
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
};
