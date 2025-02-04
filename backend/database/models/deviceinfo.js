'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class DeviceInfo extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  };
  DeviceInfo.init({
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    user_id: DataTypes.UUID,
    device_id: DataTypes.STRING,
    device_type: DataTypes.STRING,
    fcm: DataTypes.STRING,
    extra: DataTypes.STRING
  }, {
    sequelize,
    modelName: 'DeviceInfo',
    underscored: true,
    freezeTableName: true
  });
  return DeviceInfo;
};
