const {Unit, sequelize} = require("../../../../../database/models");
const messages = require("../../../../../helper/message.helper");
const {Op} = require("sequelize")
const {getStepOfAuthorization} = require("../../registration/jobber.register");

module.exports = {

    create: async function (req, res) {
        let userId = req.user.id;
        let stepAuth = {code: -1};
        if (userId === "ADMIN") {
            stepAuth.code = 3;
            userId = null
        }
        else {
            stepAuth = await getStepOfAuthorization(userId);
        }
        if (stepAuth.code === 3) {
            const {title} = req.body;
            if (title) {
                if (title.length <= process.env.UNIT_LIMIT_TITLE) {
                    Unit.findOrCreate({
                            where: {title: title.toLowerCase()},
                        }
                    ).then(response => {
                        res.scaffold.add({...response[0].dataValues, created_new: response[1]})
                    }).catch(err => {
                        res.scaffold.failed(err)
                    })
                } else {
                    res.scaffold.failed(messages.unitShouldLessThanSomeCharacter)
                }
            } else {
                res.scaffold.failed(messages.parameterIsRequire)
            }
        }
        else {
            res.scaffold.failed(messages.jobberIsNotAuthorized)
        }

    },

    search: async function (req,res) {
        const {s} = req.body;
        if (s) {
            try {
                const units = await sequelize.query('SELECT id, title FROM public."Units"  WHERE unaccent(\'unaccent\', "Units"."title") ILIKE :q OR "Units"."title" ILIKE :q', {
                    replacements: {
                        q: `%${s.toLowerCase()}%`
                    },
                    nest: true
                });
                res.scaffold.add({items: units})
            }
            catch (e) {
                res.scaffold.failed(e.message)
            }
        }
        else {
            res.scaffold.failed(messages.parameterIsRequire)
        }
    },

    getAll: async function (req, res) {
        try {
            const units = await Unit.findAll();
            res.scaffold.add({items: units})
        } catch (err) {
            res.scaffold.failed(err)
        }
    },

    delete: async function (req, res) {
        const {id} = req.body;
        if (id) {
            Unit.destroy({
                where: {id: id}
            }).then(response => {
                res.scaffold.success()
            }).catch(err => {
                res.scaffold.failed(err.message)
            })
        } else {
            res.scaffold.failed(messages.parameterIsRequire)
        }
    },
    edit: async function (req, res) {
        const {id,title} = req.body;
        if (id && title) {
            Unit.update({title: title}, {
                where: {id: id}
            }).then(response => {
                res.scaffold.success()
            }).catch(err => {
                res.scaffold.failed(err.message)
            })
        } else {
            res.scaffold.failed(messages.parameterIsRequire)
        }
    }
};
