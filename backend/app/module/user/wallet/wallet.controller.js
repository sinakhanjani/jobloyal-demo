const {Wallet} = require("../../../../database/models");

const amountOfWallet = async function (userId) {
    const wallet = await Wallet.findOne({
        where: {
            user_id: userId
        }
    });
    const amount = wallet ? wallet.amount || 0 : 0;
    return parseFloat(amount)
};

module.exports = {

    getWalletCredit :async (req, res) => {

        res.scaffold.add({credit: await amountOfWallet(req.user.id)})
    },
    amountOfWallet
};
