const express = require('express')
const structure = require('../../middlewaire/response.structure')
const { send,check } = require('./otp');
const {getLastVersion} = require("./version.control/version.controller")

const router = new express.Router()

router.post('/otp/send',structure, send);
router.post('/otp/check',structure, check);
router.post('/version',structure, getLastVersion);


module.exports = router
