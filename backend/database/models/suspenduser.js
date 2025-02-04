'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class SuspendUser extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  };
  SuspendUser.init({
    user_id: DataTypes.UUID,
    reason: DataTypes.STRING,
    system: DataTypes.BOOLEAN,
    finite: DataTypes.BOOLEAN,
    expired: DataTypes.DATE
  }, {
    sequelize,
    modelName: 'SuspendUser',
    underscored: true,
    tableName: 'SuspendUsers'
  });
  return SuspendUser;
};
