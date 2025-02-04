const {JobberDailyStatus, sequelize, JobberJob,JobberService} = require("../../../../database/models");
const messages = require("../../../../helper/message.helper");
const axios = require('axios');
const {Op} = require('sequelize');
const {getLastLocationOfJobber} = require('../daily/jobber.location');
const {getStepOfAuthorization} = require('../registration/jobber.register');

module.exports = {

    create: async function (req, res) {
        const userId = req.user.id;
        const stepAuth = await getStepOfAuthorization(userId);
        if (stepAuth.code === 3) {
            const {status, jobId} = req.body;
            const jobberJob = await JobberJob.findOne({
                where: {
                    job_id: jobId,
                    jobber_id: userId
                }
            });
            if (jobberJob) {
                if (jobberJob.enabled === true) {
                    const jobberService = await JobberService.count({
                        where: {
                            job_id: jobId,
                            jobber_id: userId
                        }
                    });
                    if (jobberService > 0) {
                        if (status && jobId) {
                            const llocation = await getLastLocationOfJobber(userId);
                            if (llocation && ((llocation.shouldUpdate === false && status === 'online') || status === 'offline')) {
                                const today = new Date().toISOString().substring(0, 10);
                                const lastStatusOfJobber = await JobberDailyStatus.findOne({
                                    where: {
                                        jobber_id: userId,
                                        created_at: {[Op.gte]: today}
                                    }, order: [['created_at', 'DESC']]
                                });
                                if (lastStatusOfJobber === null || (lastStatusOfJobber != null && lastStatusOfJobber.status !== 'busy')) {
                                    JobberDailyStatus.create({
                                        "status": status,
                                        "jobber_id": userId,
                                        "job_id": jobId
                                    }).then(result => {
                                        res.scaffold.add(result)
                                    }).catch(err => {
                                        res.scaffold.failed(err.message)
                                    })
                                } else {
                                    res.scaffold.failed(messages.jobberIsBusy)
                                }
                            } else {
                                res.scaffold.failed(messages.jobberShouldUpdateLocation)
                            }
                        } else {
                            res.scaffold.failed(messages.parameterIsRequire)
                        }
                    } else {
                        res.scaffold.failed(messages.jobWithZeroServiceCantOnline)
                    }
                } else {
                    res.scaffold.failed(messages.disabledJobNotTurnOn)
                }
            } else {
                res.scaffold.failed(messages.jobberHasNotThisJob)
            }
        } else {
            res.scaffold.failed(messages.jobberIsNotAuthorized)
        }
    },
    get: async function (req, res) {
    }
};
