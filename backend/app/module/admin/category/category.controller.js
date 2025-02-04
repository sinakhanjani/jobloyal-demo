const {Category} = require("../../../../database/models");
const messages = require("../../../../helper/message.helper");

module.exports = {

    create : async function (req,res) {
        const {title_fr,title_en,parent} = req.body;
        try {
            const newCat = await Category.create({
                title: {fr:title_fr,en:title_en},
                parent: parent
            });
            res.scaffold.add({...newCat.dataValues,name: newCat.title["en"] + " - " +  newCat.title["fr"]})
        }
        catch (e) {
            res.scaffold.failed(e)
        }
    },

    edit : async function (req, res) {
        const {title_fr,title_en,parent,id} = req.body;
        if (id) {
            let updateElements = {};
            if (title_fr && title_en) {
                updateElements.title = {};
                updateElements.title.fr = title_fr;
                updateElements.title.ch = title_fr;
                updateElements.title.en = title_en
            }
            if (parent) {
                updateElements.parent = parent
            }
            Category.update(
            updateElements,
            {where: {id: id}})
            .then(result =>
                res.scaffold.success()
            )
            .catch(err =>
                res.scaffold.failed(err)
            )
        }
        else {
            res.scaffold.failed(messages.idIsRequire)
        }
    },

    delete : async function (req,res) {
        const {id} = req.body;
        Category.destroy({
            where: {
                id: id
            }
        }).then(result => {
            res.scaffold.success()
        }).catch(err => {
            res.scaffold.failed(err.name)
        })
    },

    getCategories : async function (req,res) {
        const categories = await Category.findAll();
        const region = req.user.region;
        res.scaffold.add({items: getChild(categories,null,region)})
    }
};

function getChild(categories,id,region) {
    let cats = [];
    for (const cat of categories) {
        if (cat.parent === id) {
            if (region) {
                cat.title = cat.title[region]
            }
            else {
                cat.dataValues.name = cat.title["en"] + " - " +  cat.title["fr"]
            }
            delete cat.dataValues.parent;
            cats.push({...cat.dataValues,children: getChild(categories,cat.id,region)})
        }
    }
    return cats.length === 0 ? undefined : cats
}
