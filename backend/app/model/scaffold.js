const message = require('../../helper/message.helper')


module.exports = function (response) {
    return {
        res: {
            success: true,
            data: null,
            message: '',
            withMessage: function (message) {
                this.message = message
                return this
            },
            addRecord: function (records) {
                this.records = records
                return this
            }
        },
        add: function (data) {
            this.res.data = data
            this.res.success = true
            this.res.message = 'success'
            this.res.code = 0
            this.res.records = undefined
            response.send(this.res)
        },

        notfound: function () {
            this.res.data = undefined
            this.res.success = false
            this.res.message = 'not found'
            this.res.records = undefined
            response.code(404).send(this.res)
        },

        success: function () {
            this.res.data = undefined
            this.res.success = true
            this.res.message = 'success'
            this.res.code = 0
            this.res.records = undefined
            response.send(this.res)
        },

        failed: function (message, code = 200) {
            this.res.data = undefined;
            this.res.success = false;
            if (message.hasOwnProperty("res")) {
                this.res.message = message.res;
                this.res.code = message.code
            }
            else {
                this.res.message = message
                this.res.code = 500
            }
            this.res.records = undefined;
            response.status(code).send(this.res)
        },

        unknown: function () {
            this.res.data = undefined
            this.res.success = false
            this.res.message = message.unknown.res
            this.res.records = undefined
            response.send(this.res)
        }
    }
}
