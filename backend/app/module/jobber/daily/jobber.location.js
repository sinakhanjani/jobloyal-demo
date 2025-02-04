const {JobberLocation,
        sequelize} = require("../../../../database/models")
const axios = require('axios');
const messages = require('../../../../helper/message.helper')

async function getLastLocationOfJobber(jobber_id) {
    const locationOfJobber = await sequelize.query('SELECT id, jobber_id, location,  longitude(location),latitude(location), address, created_at as "createdAt" FROM public."JobberLocations" WHERE jobber_id = :jobber_id order by created_at DESC limit 1', {
        replacements: {
            jobber_id: jobber_id
        },
        nest: true,
        plain: true,
        raw: true
    });
    if (locationOfJobber) {
        const diff = locationOfJobber.createdAt - new Date(Date.now() - 60000 * parseInt(process.env.EXPIRE_LOCATION_AS_MINITUE));
        locationOfJobber.shouldUpdate = diff <= 0;
        return locationOfJobber;
    }
    return null
}

module.exports = {

    create : async function (req,res) {
        const {latitude,longitude} = req.body;
        const jobber_id = req.user.id;
        if (latitude && longitude) {
            let address = null;
            const geocoding = await axios.get(`https://api.codezap.io/v1/reverse?lat=${latitude}&lng=${longitude}`,
                {headers: {"api-key": process.env.API_KEY_CODEZAP}});
            if (geocoding.data.display_name) {
                address = geocoding.data.display_name
            }
            const earth = await sequelize.query('INSERT INTO public."JobberLocations"(jobber_id,location,address,created_at) SELECT :jobber_id,ll_to_earth(:latitude, :longitude) as location,:address,NOW()',
                {
                    replacements: {
                        latitude: latitude,
                        longitude: longitude,
                        address: address,
                        jobber_id: jobber_id
                    },
                    nest: true
                });
            const loc = await getLastLocationOfJobber(jobber_id);
            res.scaffold.add(loc)
        }
        else {
            res.scaffold.failed(messages.parameterIsRequire)
        }
    },

    getLastLocation: async function (req,res) {
        const jobber_id = req.user.id;
        try {
            const loc = await getLastLocationOfJobber(jobber_id);
            res.scaffold.add(loc)
        }
        catch (e) {
            res.scaffold.failed(e.message)
        }
    },
    getLastLocationOfJobber
};
