const jwt = require('jsonwebtoken');

module.exports = {
    create : function (id,region, device_id) {
        return {
            token: jwt.sign({
                id: id,
                region: region,
                device: device_id
            }, process.env.JWT_SECRET_USER, { expiresIn: '1y' })
        }
    }
};
