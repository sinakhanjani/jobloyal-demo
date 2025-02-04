const express = require('express')
const auth = require('../../../middlewaire/auth.admin')
const jobController = require("./job.controller")
const router = new express.Router()

router.post('/create',auth, jobController.create)
router.post('/delete',auth, jobController.delete)
router.post('/all',auth, jobController.getAllJobInCategory)
router.post('/edit',auth, jobController.editJobTitle)
router.post('/anything',auth, jobController.getAll)

module.exports = router
