const jwt = require('jsonwebtoken')
const scaffold = require('../model/scaffold')
const message = require('../../helper/message.helper')
const structure = require('./response.structure')

const auth = async function (req, res, next) {

    try {
        const token = req.header('Authorization').replace('Bearer ', '')
        const decoded = jwt.verify(token, process.env.JWT_SECRET_ADMIN)
        req.user = {id: "ADMIN"}
        //TODO: check user has been existed (with decoded._id or every variable contains in jwt) in your db and have permissions
        // remind: if user not have been existed, throw the function with ``throw new Error('authentication error')``

        await structure(req,res,next)
    } catch (e) {
        const response = scaffold(res).failed(message.authenticate, 401)
        res.status(401).send(response)
    }
}

module.exports = auth;
