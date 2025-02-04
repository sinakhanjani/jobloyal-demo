'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class Version extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  };
  Version.init({
    device_type: {
      type: DataTypes.ENUM,
      values: ['android','ios']
    },
    is_jobber_app: DataTypes.BOOLEAN,
    description: DataTypes.TEXT,
    force: DataTypes.BOOLEAN,
    link: DataTypes.TEXT,
    version_code: DataTypes.INTEGER,
  }, {
    sequelize,
    modelName: 'Version',
    underscored: true,
    tableName: 'Versions'
  });
  return Version;
};
