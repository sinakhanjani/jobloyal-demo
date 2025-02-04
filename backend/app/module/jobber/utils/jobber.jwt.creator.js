const jwt = require('jsonwebtoken')

module.exports = {
    create : function (id,region,deviceId) {
        return {
            token: jwt.sign({
                id: id,
                region: region,
                device: deviceId
            }, process.env.JWT_SECRET_JOBBER, { expiresIn: '1y' })
        }
    }
}
