'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class Service extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  };
  Service.init({
    id: {type: DataTypes.UUID,defaultValue: DataTypes.UUIDV4,
    primaryKey:true},
    title: DataTypes.STRING,
    default_unit_id: DataTypes.UUID,
    creator_user_id: DataTypes.UUID,
    job_id:DataTypes.UUID
  }, {
    sequelize,
    modelName: 'Service',
    underscored: true,
    tableName: 'Services'
  });
  Service.associate = function (model) {
    Service.belongsTo(model.Jobber,{foreignKey: {name: 'creator_user_id'}})
    Service.belongsTo(model.Unit,{foreignKey: {name: 'default_unit_id'},as:'unit'})
    Service.belongsTo(model.Job,{foreignKey: {name: 'job_id'}})
  }
  return Service;
};
