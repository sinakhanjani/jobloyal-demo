const categoryController = require("./category.controller")
const express = require('express')
const auth = require('../../../middlewaire/auth.admin')
const router = new express.Router()

router.post('/create',auth, categoryController.create)
router.post('/edit',auth, categoryController.edit)
router.post('/delete',auth, categoryController.delete)
router.get('/all',auth, categoryController.getCategories)

module.exports = router
