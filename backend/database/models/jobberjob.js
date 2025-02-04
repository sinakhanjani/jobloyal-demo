'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class JobberJob extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  };
  JobberJob.init({
    jobber_id: DataTypes.UUID,
    job_id: DataTypes.UUID,
    enabled: {
      type: DataTypes.BOOLEAN,
      defaultValue: true
    }
  }, {
    sequelize,
    modelName: 'JobberJob',
    underscored: true,
    tableName: "JobberJobs",
    timestamps:false,
    paranoid: true,
  });
    JobberJob.associate = (models) => {
      JobberJob.belongsTo(models.Jobber, {foreignKey: {name: "jobber_id", type: DataTypes.UUID}});
      JobberJob.belongsTo(models.Job, {foreignKey: {name: "job_id", type: DataTypes.UUID},as:'job'});
    }
    JobberJob.removeAttribute('id');
  return JobberJob;
};
