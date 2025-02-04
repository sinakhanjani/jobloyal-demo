'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class Payment extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  };
  Payment.init({
    id:{
      type: DataTypes.UUID,
      primaryKey: true,
      defaultValue: DataTypes.UUIDV4,
      allowNull: false,
      autoIncrement: false,
    },
    user_id: DataTypes.UUID,
    request_id: DataTypes.UUID,
    authority: DataTypes.STRING,
    use_wallet: DataTypes.BOOLEAN,
    total_amount: DataTypes.DECIMAL(10,2),
    payable_amount: DataTypes.DECIMAL(10,2),
    status:  DataTypes.ENUM({values: ['created','success','wallet','failed']})
  }, {
    sequelize,
    modelName: 'Payment',
    underscored: true,
    tableName: 'Payments'
  });
  return Payment;
};
