'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class RequestService extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  };
  RequestService.init({
    request_id: DataTypes.UUID,
    service_id: DataTypes.UUID,
    count: DataTypes.INTEGER,
    price: DataTypes.DECIMAL(10,2),
    accepted: DataTypes.BOOLEAN
  }, {
    sequelize,
    modelName: 'RequestService',
    tableName: 'RequestServices',
    underscored: true,
  });
  RequestService.associate = (models) => {
    RequestService.belongsTo(models.Request, {foreignKey: {name: "request_id", type: DataTypes.UUID}});
    RequestService.belongsTo(models.JobberService, {foreignKey: {name: "service_id", type: DataTypes.UUID},targetKey:'id'});
  }
  return RequestService;
};
