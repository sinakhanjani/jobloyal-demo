const jwt = require('jsonwebtoken');
const tokenCreator = require('../utilities/user.jwt.creator');
const {User,DeviceInfo,sequelize} = require("../../../../database/models");
const {amountOfWallet} = require("../wallet/wallet.controller");
const messages = require("../../../../helper/message.helper");

exportTokenFromRequest = function (req) {
    return req.header('Authorization').replace('Bearer ', '')
};

getToken = async function (req,res) {
    const token = exportTokenFromRequest(req);
    try {
        const decode = jwt.
        verify(token, process.env.JWT_SECRET_PHONE_AUTH);
        const user = await getUserByPhone(decode.phoneNumber);
        if (!user) {
            res.scaffold.success()
        }
        else {
            let region = user.region;
            if (req.body.region) {
                region = await changeRegionOfUser(req.body.region, user.id)
            }
            const deviceInfo = await DeviceInfo.create({
                user_id: user.id
            });
            res.scaffold.add(tokenCreator.create(user.id, region,deviceInfo.id))
        }
    }
    catch (e) {
        res.scaffold.failed(e.message)
    }
};

changeRegionRequest = async function (req,res) {
    const {region} = req.body;
    let acceptedRegion = await changeRegionOfUser(region, req.user.id);
    res.scaffold.add(tokenCreator.create(req.user.id, acceptedRegion, req.user.device))
};

changeRegionOfUser = async function (region, userId) {
    let localeCode = 'en';
    if (region) {
        if (region === "fr" || region === "en") {
            localeCode = region
        }
    }
    await User.update({
        region: localeCode
    },{
        where: {
            id: userId
        }
    });
    return localeCode
};

createNewUser = async function (req,phoneNumber) {
    const { name, family, gender, email, address, birthday, region } = req.body;
    let localeCode = 'en';
    if (region) {
        if (region === "fr" || region === "en") {
            localeCode = region
        }
    }
    else {
        if (phoneNumber.startsWith("+33") || phoneNumber.startsWith("+41")) {
            localeCode = 'fr'
        }
    }
    return await User.create({
        name: name,
        family: family,
        gender: gender,
        email: email,
        address: address,
        phone_number: phoneNumber,
        birthday: birthday,
        region: localeCode
    })
};

getUserByPhone = async function (phoneNumber) {
    const user = await User.findOne({
        where: { phone_number: phoneNumber },
        attributes: ['id','region']
    });
    if (!user) {
        return null
    }
    else {
        return user
    }
};

registerUser = async function (req,res) {
    const token = exportTokenFromRequest(req);
    try {
        const decode = jwt.verify(token, process.env.JWT_SECRET_PHONE_AUTH);
        const newJobber = await createNewUser(req,decode.phoneNumber);
        const deviceInfo = await DeviceInfo.create({
            user_id: newJobber.id
        });
        res.scaffold.add(tokenCreator.create(newJobber.id,newJobber.region, deviceInfo.id))
    }
    catch (e) {
        res.scaffold.failed(e)
    }
};

editProfile = async function (req,res) {
    const user_id = req.user.id;
    const {name,family,email,address,gender,birthday} = req.body;
    try {
        await User.update({
                name,
                family,
                email,
                address,
                gender,
                birthday
        }, {
            where: {
                id: user_id
            }
        });
        res.scaffold.success()
    }
    catch (e) {
        res.scaffold.failed(e.message)
    }
};

getProfile = async function (req, res) {
    const userId = req.user.id;
    const user = await User.findOne({
        where: { id: userId },
    });
    user.dataValues.credit = await amountOfWallet(req.user.id);
    res.scaffold.add(user)
};
deleteUser = async function (req, res) {
    const userId = req.user.id;
    const region = req.user.region;
    const request = await sequelize.query('SELECT "Request"."id" FROM "Requests" AS "Request" WHERE "Request"."user_id" = :user_id AND (("Request"."status" = \'finished\' OR ("Request"."status" = \'created\' AND "Request"."created_at" > NOW() - INTERVAL :req_time_life)) OR "Request"."status" = \'paid\'  OR "Request"."status" = \'accepted\' OR "Request"."status" = \'arrived\' OR "Request"."status" = \'started\') ORDER BY "Request"."created_at" DESC LIMIT 1', {
        replacements: {
            user_id: userId,
            region: region,
            req_time_life: `${process.env.REQUEST_LIFE_TIME} minutes`
        },
        nest: true,
    });
    if (request.length > 0) {
        res.scaffold.failed(messages.userHaveLiveRequest)
    } else {
        const date = new Date().toISOString().substring(0,10);
        try {
            await User.update({
                phone_number: sequelize.literal('CONCAT(\''+ date +'del:\', "phone_number")')
            }, {
                where: {
                    id: req.user.id
                }
            });
            await DeviceInfo.destroy({
                where: {
                    id: req.user.device
                }
            });
            await User.destroy({
                where: {
                    id: req.user.id
                }
            });
            res.scaffold.success()
        }
        catch (e) {
            res.scaffold.failed(messages.oneTimeDeleteAccountInDay)
        }
    }

};

module.exports = {getToken,registerUser,editProfile, getProfile, changeRegionRequest,deleteUser};
