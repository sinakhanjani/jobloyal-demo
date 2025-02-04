'use strict';
const {
  Model
} = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class Job extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  };
  Job.init({
    id: {
      type: DataTypes.UUID,
      primaryKey: true,
      defaultValue: DataTypes.UUIDV4,
    },
    title: DataTypes.JSON,
    category_id: DataTypes.UUID
  }, {
    sequelize,
    modelName: 'Job',
    tableName:"Jobs",
    underscored: true,
  });
  Job.associate = (models) => {
    Job.belongsTo(models.Category,{foreignKey:{name:"category_id",type:DataTypes.UUID}});
    Job.belongsToMany(models.Jobber, { through: 'JobberJob',foreignKey: {name: 'job_id'}  });
  };
  return Job;
};
