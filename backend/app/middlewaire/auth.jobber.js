const jwt = require('jsonwebtoken');
const scaffold = require('../model/scaffold');
const message = require('../../helper/message.helper');
const structure = require('./response.structure');
const {SuspendUser,sequelize,Jobber} =  require("../../database/models");

const checkNotSuspend = async function (user_id) {
    const suspend = await SuspendUser.findOne({
        where: {
            user_id: user_id
        }
    });
    if (suspend) {
        if (suspend.finite === true) {
            if (suspend.expired != null && suspend.expired < new Date()) {
                return true
            }
        }
        return false
    }
    return true
};
const checkIsNotDeleted = async function (user_id) {
    const jobber = await Jobber.findOne({
        where: {
            id: user_id
        }
    });
    return jobber;
};

const authJobber = async function (req, res, next) {

    try {
        const token = req.header('Authorization').replace('Bearer ', '');
        const decoded = jwt.verify(token, process.env.JWT_SECRET_JOBBER);
        req.user = decoded;
        const isFree = await checkNotSuspend(req.user.id);
        if (!isFree && req.url !== "/suspend/detail") {
            throw new Error('user is suspend')
        }
        const userIsExist = await checkIsNotDeleted(req.user.id);
        if (!userIsExist) {
            throw new Error("user not authorized")
        }
        await structure(req,res,next)
    } catch (e) {
        let response;
        if (e.message === "user is suspend") {
            response = scaffold(res).failed(message.suspend, 403)
        }
        else {
            response = scaffold(res).failed(message.authenticate, 401);
        }
        res.status(401).send(response)
    }
};

module.exports = authJobber;
