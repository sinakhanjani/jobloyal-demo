'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class FailedDeposits extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  };
  FailedDeposits.init({
    deposit_id: DataTypes.STRING,
    ref_code: DataTypes.STRING,
    message: DataTypes.TEXT
  }, {
    sequelize,
    modelName: 'FailedDeposits',
    underscored: true,
    tableName: 'FailedDeposits'
  });
  return FailedDeposits;
};
