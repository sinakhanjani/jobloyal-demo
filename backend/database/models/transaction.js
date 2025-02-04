'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class Transaction extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  };
  Transaction.init({
    id:{
      type: DataTypes.UUID,
      primaryKey: true,
      defaultValue: DataTypes.UUIDV4,
      allowNull: false,
      autoIncrement: false,
    },
    pid: DataTypes.UUID,
    type:  DataTypes.ENUM({values: ['wallet','payment','deposit']}),
    amount: DataTypes.DECIMAL(10,2),
    reference_code: DataTypes.STRING
  }, {
    sequelize,
    modelName: 'Transaction',
    underscored: true,
    tableName: 'Transactions'
  });
  return Transaction;
};
