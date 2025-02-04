'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class JobberLocation extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  };
  JobberLocation.init({
    jobber_id: DataTypes.UUID,
    location: 'earth',
    address: DataTypes.STRING
  }, {
    sequelize,
    modelName: 'JobberLocation',
    underscored: true,
    tableName: 'JobberLocations',
    updatedAt: false
  });
  return JobberLocation;
};
