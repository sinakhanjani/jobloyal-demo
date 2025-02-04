'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class JobberDailyStatus extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  };
  JobberDailyStatus.init({
    status: DataTypes.STRING,
    jobber_id: DataTypes.UUID,
    job_id: DataTypes.UUID
  }, {
    sequelize,
    updatedAt:false,
    underscored:true,
    modelName: 'JobberDailyStatus',
    tableName: 'JobberDailyStatus'
  });
  return JobberDailyStatus;
};
