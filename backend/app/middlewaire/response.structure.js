const scaffold = require('../model/scaffold')
const message = require('../../helper/message.helper')

const ResponseStructure = async function (req, res, next){

    try {
        res.scaffold = scaffold(res)
        next()

    } catch (e) {
       scaffold.failed(message.unknown)
    }
}

module.exports = ResponseStructure
