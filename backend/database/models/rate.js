'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class Rate extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  };
  Rate.init({
    jobber_id: DataTypes.UUID,
    job_id: DataTypes.UUID,
    star1: DataTypes.INTEGER,
    star2: DataTypes.INTEGER,
    star3: DataTypes.INTEGER,
    star4: DataTypes.INTEGER,
    star5: DataTypes.INTEGER,
    rate: DataTypes.DECIMAL(1,1),
    work: DataTypes.INTEGER
  }, {
    sequelize,
    modelName: 'Rate',
    tableName: 'Rates',
    underscored: true,
  });
  return Rate;
};
