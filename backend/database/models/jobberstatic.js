'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class JobberStatic extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  };
  JobberStatic.init({
    jobber_id: DataTypes.UUID,
    sms_enabled: DataTypes.BOOLEAN,
    notification_enabled: DataTypes.BOOLEAN,
    pony_period: DataTypes.INTEGER,
    card_number: DataTypes.STRING
  }, {
    sequelize,
    modelName: 'JobberStatic',
    underscored: true,
    tableName: 'JobberStatics'
  });
  return JobberStatic;
};
