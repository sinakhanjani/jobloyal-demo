const jwt = require('jsonwebtoken')
const messages = require("../../../../helper/message.helper")
user = {
    userId: "1",
    role: 'SA',
    displayName: "Houman Aghahosseini",
    email: "jasonalexander@gmail.com",
    photoURL: "/assets/images/face-6.jpg",
    age: 25
};
module.exports = {
    login: async function (req,res) {
        const {username,password} = req.body;
        if (username === process.env.USERNAME_PANEL && password === process.env.PASSWORD_PANEL) {
            res.scaffold.add({
                ...user,
                token: jwt.sign({}, process.env.JWT_SECRET_ADMIN, { expiresIn: '1y' })})
        }
        else {
            res.scaffold.failed(messages.wrongPassword)
        }
    },
    loginWithToken: async function (req,res) {
            res.scaffold.add({
                ...user,
                token: jwt.sign({}, process.env.JWT_SECRET_ADMIN, { expiresIn: '1y' })})
    }
};
