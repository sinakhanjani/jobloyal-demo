'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class RequestStatusReport extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  };
  RequestStatusReport.init({
    request_id: DataTypes.UUID,
    status: DataTypes.STRING,
    data: DataTypes.STRING
  }, {
    sequelize,
    modelName: 'RequestStatusReport',
    freezeTableName: true,
    underscored: true,
    updatedAt: false
  });
  return RequestStatusReport;
};
