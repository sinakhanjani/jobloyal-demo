'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class FailedTransaction extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  };
  FailedTransaction.init({
    id:{
      type: DataTypes.UUID,
      primaryKey: true,
      defaultValue: DataTypes.UUIDV4,
      allowNull: false,
      autoIncrement: false,
    },
    pid: DataTypes.UUID,
    message: DataTypes.STRING,
    code: DataTypes.INTEGER
  }, {
    sequelize,
    modelName: 'FailedTransaction',
    underscored: true,
    tableName: 'FailedTransactions'
  });
  return FailedTransaction;
};
