'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class Deposit extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  };
  Deposit.init({
    id:{
      type: DataTypes.UUID,
      primaryKey: true,
      defaultValue: DataTypes.UUIDV4,
      allowNull: false,
      autoIncrement: false,
    },
    jobber_id: DataTypes.UUID,
    amount: DataTypes.DECIMAL(10,2),
    status: DataTypes.ENUM({values: ['queue','pending','success','failed']}),
    ref_code: DataTypes.STRING
  }, {
    sequelize,
    modelName: 'Deposit',
    underscored: true,
    tableName: 'Deposits'
  });
  return Deposit;
};
