const {Version} = require("../../../../database/models");
const messages = require("../../../../helper/message.helper")
module.exports = {

    getLastVersion : async function (req,res) {
        const {device_type,is_jobber_app} = req.body;
        if (device_type) {
            const version = await Version.findOne({
                where: {
                    device_type: device_type,
                    is_jobber_app: is_jobber_app
                },
                limit: 1,
                order: [['created_at', 'desc']]
            });
            if (version && version.dataValues) {
                version.dataValues.period = 1;
            }
            res.scaffold.add(version)
        }
        else {
            res.scaffold.failed(messages.parameterIsRequire)
        }
    },

    addVersion : async function (req,res) {
        const {device_type,is_jobber_app,description,force,link,version_code} = req.body;
        const version = await Version.create({
            device_type,
            is_jobber_app,
            description,
            force,
            link,
            version_code
        });
        res.scaffold.add(version)
    },

    deleteVersion: async function (req,res) {
        const {id} = req.body;
        const result = await Version.destroy({where: {id: id}})
        res.scaffold.success()
    },

    getAllVersions: async function (req,res) {
        const versions = await Version.findAll({
            order: [['created_at','desc']]
        });
        res.scaffold.add({items: versions})
    }
};
